import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:math' as math;
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_punto_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componente_reproductor_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';

import 'catalogo_mapa_3d.dart';
import 'servidor_mapa_local.dart';

class PantallaMapa3D extends StatefulWidget {
  const PantallaMapa3D({
    super.key,
    this.idPuntoInicial,
    this.onBack,
    this.activo = true,
  });
  final String? idPuntoInicial;
  final VoidCallback? onBack;
  final bool activo;

  @override
  State<PantallaMapa3D> createState() => _PantallaMapa3DState();
}

class _PantallaMapa3DState extends State<PantallaMapa3D>
    with WidgetsBindingObserver {
  MapLibreMapController? _map;

  @visibleForTesting
  MapLibreMapController? get controladorParaPruebas => _map;
  @visibleForTesting
  bool get mapaListoParaPruebas => _listo && _dibujado;

  String? _estilo;
  final _ancla = ValueNotifier<Offset?>(null);
  final _detalleVentana = ValueNotifier<double>(1);
  Size _tamanoMapa = Size.zero;
  bool _proyectando = false, _fichaAbierta = false;
  int _generacion = 0;
  final _inicioCarga = Stopwatch();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant PantallaMapa3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activo != oldWidget.activo) _actividad();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _actividad();
    } else {
      unawaited(_map?.pauseMap() ?? Future<void>.value());
    }
  }

  void _actividad() {
    final map = _map;
    if (map == null) return;
    unawaited(
      widget.activo && !_fichaAbierta ? map.resumeMap() : map.pauseMap(),
    );
  }

  ServidorMapaLocal? _server;
  CatalogoMapa3D? _catalogo;
  RepositorioPatrimonio? _repositorio;
  List<PuntoMapa3D> _puntos = [];
  PuntoMapa3D? _seleccionado;
  Timer? _timeout;
  String? _error;
  bool _dibujado = false;
  bool _listo = false, _modo3d = true, _buscandoUbicacion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = context.read<RepositorioPatrimonio>();
    if (_repositorio != repo) {
      _repositorio?.removeListener(_actualizarCatalogo);
      _repositorio = repo;
      repo.addListener(_actualizarCatalogo);
      unawaited(_iniciar());
    }
  }

  Future<void> _iniciar() async {
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      setState(() => _error = 'El mapa 3D está preparado para Android e iOS.');
      return;
    }
    _inicioCarga.reset();
    _inicioCarga.start();
    try {
      _catalogo = await CatalogoMapa3D.cargar();
      if (!mounted) return;
      _puntos = _catalogo!.reconciliar(_repositorio!.puntos);
      final server = await ServidorMapaLocal.abrir(
        imagenes: _imagenesLocales(),
        mapaContinuo: true,
      );
      if (!mounted) {
        await server.cerrar();
        return;
      }
      _server = server;
      final style =
          jsonDecode(
                await rootBundle.loadString('assets/mapa_3d/style-native.json'),
              )
              as Map<String, dynamic>;
      String url(String value) => server.inicio
          .resolve(value)
          .toString()
          .replaceAll('%7B', '{')
          .replaceAll('%7D', '}');
      style['glyphs'] = url(style['glyphs']);
      for (final source in (style['sources'] as Map).values) {
        if (source['tiles'] != null) {
          source['tiles'] = (source['tiles'] as List)
              .map((tile) => url(tile as String))
              .toList();
        }
        if (source['url'] is String) source['url'] = url(source['url']);
        if (source['data'] is String) source['data'] = url(source['data']);
      }
      style['sources']['heritage']['data'] = _geoPuntos();
      style['sources']['usuario'] = {
        'type': 'geojson',
        'data': {'type': 'FeatureCollection', 'features': []},
      };
      style['layers'].add({
        'id': 'ubicacion-usuario',
        'type': 'circle',
        'source': 'usuario',
        'paint': {
          'circle-radius': 7,
          'circle-color': '#247edb',
          'circle-stroke-width': 3,
          'circle-stroke-color': '#ffffff',
        },
      });
      // Motor C++ de Android/iOS; las tarjetas Flutter se componen sobre su textura.
      MapLibreMap.useHybridComposition = true;
      if (!mounted) return;
      setState(() => _estilo = jsonEncode(style));
      _timeout = Timer(const Duration(seconds: 30), () {
        if (mounted && !_dibujado) {
          _fallo('La carga del mapa demoró demasiado. Volvé a intentarlo.');
        }
      });
    } catch (error) {
      debugPrint('Mapa nativo: $error');
      if (mounted) _fallo('No se pudo preparar el mapa. Volvé a intentarlo.');
    }
  }

  Map<String, dynamic> _geoPuntos() => {
    'type': 'FeatureCollection',
    'features': [
      for (final p in _puntos)
        {
          'type': 'Feature',
          'id': p.numero,
          'geometry': {
            'type': 'Point',
            'coordinates': [p.punto.lng, p.punto.lat],
          },
          'properties': {
            'id': p.punto.id,
            'name': p.punto.nombre,
            'number': p.numero,
            'selected': p == _seleccionado,
          },
        },
    ],
  };

  Future<void> _estiloCargado() async {
    if (!mounted || _map == null) return;
    setState(() {
      _listo = true;
      _error = null;
    });
    await _centrar('centro', false);
    if (widget.idPuntoInicial != null) {
      await _seleccionar(widget.idPuntoInicial!);
    }
    debugPrint(
      'QA_NATIVO_LISTO: ${_inicioCarga.elapsedMilliseconds} ms; ${_puntos.length} puntos',
    );
    _actividad();
  }

  Future<void> _seleccionar(String id) async {
    final point = _porId(id), map = _map;
    if (!_listo || point == null || map == null) return;
    _ancla.value = null;
    setState(() => _seleccionado = point);
    await map.setGeoJsonSource('heritage', _geoPuntos());
    await map.updateContentInsets(
      EdgeInsets.only(top: _tamanoMapa.height * .32),
      false,
    );
    await map.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(point.punto.lat, point.punto.lng),
          zoom: point.numero == 21 ? 17.1 : 18.1,
          tilt: _modo3d ? 45 : 0,
          bearing: -10,
        ),
      ),
      duration: const Duration(milliseconds: 450),
    );
    await _actualizarAncla();
  }

  void _cerrarSeleccion() {
    setState(() => _seleccionado = null);
    _ancla.value = null;
    unawaited(
      _map?.setGeoJsonSource('heritage', _geoPuntos()) ?? Future<void>.value(),
    );
    unawaited(
      _map?.updateContentInsets(EdgeInsets.zero, false) ?? Future<void>.value(),
    );
  }

  Future<void> _actualizarAncla() async {
    final point = _seleccionado, map = _map;
    if (_proyectando || point == null || map == null) return;
    _proyectando = true;
    try {
      final pos = await map.toScreenLocation(
        LatLng(point.punto.lat, point.punto.lng),
      );
      if (mounted && _seleccionado?.punto.id == point.punto.id) {
        // La proyeccion Android entrega pixeles fisicos; Flutter usa logicos.
        final scale = defaultTargetPlatform == TargetPlatform.android
            ? MediaQuery.devicePixelRatioOf(context)
            : 1.0;
        _ancla.value = Offset(
          pos.x.toDouble() / scale,
          pos.y.toDouble() / scale,
        );
        final focusZoom = point.numero == 21 ? 17.1 : 18.1;
        final zoom = map.cameraPosition?.zoom ?? focusZoom;
        final t = ((zoom - focusZoom + 2) / 2).clamp(0.0, 1.0);
        // La misma cámara gobierna posición y tamaño, sin animaciones retrasadas.
        final detail = t * t * (3 - 2 * t);
        if ((detail - _detalleVentana.value).abs() >= .005 ||
            detail == 0 ||
            detail == 1) {
          _detalleVentana.value = detail;
        }
      }
    } finally {
      _proyectando = false;
    }
  }

  Future<void> _centrar(String zone, [bool animated = true]) async {
    final map = _map;
    if (!_listo || map == null) return;
    _cerrarSeleccion();
    final points = zone == 'all'
        ? _puntos
        : _puntos.where((p) => p.numero != 21).toList();
    final lng = points.map((p) => p.punto.lng),
        lat = points.map((p) => p.punto.lat);
    final bounds = LatLngBounds(
      southwest: LatLng(lat.reduce(math.min), lng.reduce(math.min)),
      northeast: LatLng(lat.reduce(math.max), lng.reduce(math.max)),
    );
    final update = CameraUpdate.newLatLngBounds(
      bounds,
      left: 45,
      right: 45,
      top: 50,
      bottom: 110,
    );
    if (animated) {
      await map.animateCamera(
        update,
        duration: const Duration(milliseconds: 450),
      );
    } else {
      await map.moveCamera(update);
    }
    final camera = map.cameraPosition;
    if (camera != null) {
      await map.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: camera.target,
            zoom: math.min(camera.zoom, 16),
            tilt: _modo3d ? 40 : 0,
            bearing: zone == 'all' ? 40 : -10,
          ),
        ),
      );
    }
  }

  Future<void> _mapClick(math.Point<double> screen, LatLng location) async {
    if (!_listo || _map == null) return;
    final features = await _map!.queryRenderedFeatures(screen, [
      'puntos-circulos',
      'puntos-numeros',
      'castro-3d',
    ], null);
    for (final feature in features) {
      final props = feature['properties'] as Map?;
      final id = props?['id'] ?? props?['heritage_id'];
      if (id is String && _porId(id) != null) {
        await _seleccionar(id);
        return;
      }
    }
    if (mounted && _seleccionado != null) _cerrarSeleccion();
  }

  void _cameraIdle() {
    unawaited(_actualizarAncla());
  }

  void _actualizarCatalogo() {
    if (_catalogo == null || !mounted) return;
    final puntos = _catalogo!.reconciliar(_repositorio!.puntos);
    setState(() {
      _puntos = puntos;
      if (_seleccionado != null) {
        _seleccionado = _porId(_seleccionado!.punto.id);
      }
    });
    _server?.actualizarImagenes(_imagenesLocales());
    if (_listo) {
      unawaited(
        _comando('actualizar', [puntos.map((p) => p.toJson()).toList()]),
      );
    }
  }

  PuntoMapa3D? _porId(String id) {
    for (final punto in _puntos) {
      if (punto.punto.id == id) return punto;
    }
    return null;
  }

  Map<String, String> _imagenesLocales() => {
    for (final punto in _puntos)
      if (punto.imagenLocal != null)
        'imagenes/${punto.numero}.jpg': punto.imagenLocal!,
  };

  Future<void> _abrirFicha(String id) async {
    final punto = _porId(id);
    if (punto == null || !_listo) return;
    _fichaAbierta = true;
    _actividad();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaDetallePuntoAlejo(
          punto: punto.punto,
          onVerMapa: () => Navigator.of(context).pop(),
        ),
      ),
    );
    _fichaAbierta = false;
    if (mounted) {
      _actividad();
      await _actualizarAncla();
    }
  }

  Future<void> _comando(String method, List<Object?> args) async {
    final map = _map;
    if (!_listo || map == null) return;
    switch (method) {
      case 'select':
        await _seleccionar(args.first as String);
      case 'center':
        await _centrar(args.first as String);
      case 'actualizar':
        await map.setGeoJsonSource('heritage', _geoPuntos());
      case 'zoom':
        await map.animateCamera(
          CameraUpdate.zoomBy((args.first as num).toDouble()),
          duration: const Duration(milliseconds: 200),
        );
      case 'modo':
        final three = args.first as bool;
        await map.setLayerVisibility('edificios-3d', three);
        await map.setLayerVisibility('castro-3d', three);
        await map.setLayerVisibility('sombras-suelo', three);
        await map.setLayerVisibility('detalles-patrimoniales', three);
        await map.setLayerVisibility('huellas-2d', !three);
        final camera = map.cameraPosition;
        if (camera != null) {
          await map.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: camera.target,
                zoom: camera.zoom,
                bearing: camera.bearing,
                tilt: three ? 45 : 0,
              ),
            ),
            duration: const Duration(milliseconds: 300),
          );
        }
    }
  }

  void _fallo(String text) {
    _timeout?.cancel();
    setState(() => _error = text);
  }

  Future<void> _reintentar() async {
    _timeout?.cancel();
    final server = _server;
    setState(() {
      _map = null;
      _server = null;
      _estilo = null;
      _listo = false;
      _dibujado = false;
      _error = null;
      _seleccionado = null;
      _generacion++;
    });
    await server?.cerrar();
    if (mounted) await _iniciar();
  }

  Future<void> _buscar() async {
    final seleccionado = await showModalBottomSheet<PuntoMapa3D>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _BuscadorCasas(puntos: _puntos),
    );
    if (seleccionado != null && mounted) {
      await _comando('select', [seleccionado.punto.id]);
    }
  }

  Future<void> _ubicacion() async {
    setState(() => _buscandoUbicacion = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Activá la ubicación del teléfono.');
      }
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        throw StateError(
          'Habilitá el permiso de ubicación para ver dónde estás.',
        );
      }
      final location = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      await _map!.setGeoJsonSource('usuario', {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [location.longitude, location.latitude],
            },
            'properties': {},
          },
        ],
      });
      await _map!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          17,
        ),
        duration: const Duration(milliseconds: 450),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError
                  ? error.message
                  : 'No se pudo obtener tu ubicación.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _buscandoUbicacion = false);
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _repositorio?.removeListener(_actualizarCatalogo);
    WidgetsBinding.instance.removeObserver(this);
    _ancla.dispose();
    _detalleVentana.dispose();
    // Desmontar MapLibreMap libera el visor nativo y su bucle de render.
    unawaited(_server?.cerrar() ?? Future<void>.value());
    super.dispose();
  }

  Widget _visor() => LayoutBuilder(
    builder: (context, constraints) {
      _tamanoMapa = constraints.biggest;
      return MapLibreMap(
        key: ValueKey('mapa-nativo-$_generacion'),
        styleString: _estilo!,
        initialCameraPosition: const CameraPosition(
          target: LatLng(-31.3947, -58.0165),
          zoom: 15.3,
          tilt: 40,
          bearing: -10,
        ),
        minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
        compassEnabled: false,
        logoEnabled: false,
        annotationOrder: const [],
        trackCameraPosition: true,
        onMapCreated: (map) {
          _map = map;
          unawaited(map.setMaximumFps(60));
        },
        onStyleLoadedCallback: () => unawaited(_estiloCargado()),
        onMapClick: (point, location) => unawaited(_mapClick(point, location)),
        onCameraMove: (_) => unawaited(_actualizarAncla()),
        onCameraIdle: _cameraIdle,
        onMapIdle: () {
          if (mounted && !_dibujado) {
            _timeout?.cancel();
            setState(() => _dibujado = true);
            debugPrint(
              'QA_NATIVO_DIBUJADO: ${_inicioCarga.elapsedMilliseconds} ms',
            );
          }
        },
      );
    },
  );

  Widget _ventanaFlotante() => Positioned.fill(
    bottom: context.read<ControladorAudio>().tieneAudio ? 130 : 0,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final p = _seleccionado;
        if (p == null) return const SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: _detalleVentana,
          builder: (context, detail, _) {
            final width = math.min(
              244.0 + 76 * detail,
              constraints.maxWidth - 28,
            );
            final smallHeight = math.min(208.0, constraints.maxHeight * .34);
            final fullHeight = math.min(420.0, constraints.maxHeight * .57);
            final maxHeight = smallHeight + (fullHeight - smallHeight) * detail;
            return ValueListenableBuilder<Offset?>(
              valueListenable: _ancla,
              // Al panear se reutiliza el contenido; solo el zoom adapta la tarjeta.
              child: _contenidoVentana(
                p,
                width,
                maxHeight,
                math.min(128.0, constraints.maxHeight * .16) * detail,
                detail,
              ),
              builder: (context, anchor, card) {
                if (anchor == null) return const SizedBox.shrink();
                final left = (anchor.dx - width / 2)
                    .clamp(
                      14.0,
                      math.max(14.0, constraints.maxWidth - width - 14),
                    )
                    .toDouble();
                final bottom = (constraints.maxHeight - anchor.dy + 20)
                    .clamp(
                      8.0,
                      math.max(8.0, constraints.maxHeight - maxHeight - 8),
                    )
                    .toDouble();
                return Stack(
                  children: [
                    Positioned(
                      left: left,
                      bottom: bottom,
                      width: width,
                      child: card!,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ),
  );

  Widget _contenidoVentana(
    PuntoMapa3D p,
    double width,
    double maxHeight,
    double imageHeight,
    double detail,
  ) => RepaintBoundary(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          key: const ValueKey('tarjeta-patrimonial'),
          color: Colors.white,
          elevation: 8,
          shadowColor: const Color(0x5525362E),
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (p.imagenLocal != null && imageHeight > .5)
                  Opacity(
                    opacity: detail,
                    child: Image.asset(
                      p.imagenLocal!,
                      width: width,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      cacheWidth: 720,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        12 + 4 * detail,
                        10 + 4 * detail,
                        12 + 4 * detail,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'PUNTO ${p.numero} · PATRIMONIO',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    letterSpacing: .6,
                                    color: Color(0xFFA8583A),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Cerrar ventana',
                                onPressed: _cerrarSeleccion,
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                                padding: EdgeInsets.zero,
                                iconSize: 20,
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          Text(
                            p.punto.nombre,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 18 + 6 * detail,
                              height: 1.15,
                              color: Color(0xFF253B31),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.punto.direccion,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Color(0xFF6A7A72),
                            ),
                          ),
                          SizedBox(height: 10 * detail),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.topLeft,
                              heightFactor: detail,
                              child: Opacity(
                                opacity: detail,
                                child: Text(
                                  p.punto.descripcion,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Color(0xFF34483E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    12 + 4 * detail,
                    8 + 4 * detail,
                    12 + 4 * detail,
                    10 + 4 * detail,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      onPressed: () => _abrirFicha(p.punto.id),
                      child: const Text('Ver ficha completa'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        CustomPaint(size: const Size(18, 10), painter: _PuntaVentana()),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tieneAudio = context.select(
      (ControladorAudio audio) => audio.tieneAudio,
    );
    final safeTop = MediaQuery.paddingOf(context).top + 12;
    final ready = _listo && _dibujado && _error == null;
    final back =
        widget.onBack ??
        (Navigator.canPop(context) ? () => Navigator.pop(context) : null);
    return Scaffold(
      backgroundColor: const Color(0xFFD4DBD8),
      body: Stack(
        children: [
          if (_estilo != null)
            Positioned.fill(bottom: tieneAudio ? 130 : 0, child: _visor()),
          if (_listo && _error == null && _seleccionado != null)
            _ventanaFlotante(),
          if (_listo && _error == null && _seleccionado == null)
            Positioned(
              top: safeTop + 64,
              right: 12,
              child: Column(
                children: [
                  _control(
                    Icons.add,
                    'Acercar',
                    () => _comando('zoom', [0.65]),
                  ),
                  _control(
                    Icons.remove,
                    'Alejar',
                    () => _comando('zoom', [-0.65]),
                  ),
                  _control(Icons.location_city, 'Volver al centro', () {
                    setState(() => _seleccionado = null);
                    return _comando('center', ['centro']);
                  }),
                  _control(Icons.public, 'Ver toda la zona', () {
                    setState(() => _seleccionado = null);
                    return _comando('center', ['all']);
                  }),
                  _control(
                    Icons.my_location,
                    'Mi ubicación',
                    _buscandoUbicacion ? null : _ubicacion,
                  ),
                ],
              ),
            ),
          if (!_listo || !_dibujado || _error != null)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xEED4DBD8),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_error == null) const CircularProgressIndicator(),
                        const SizedBox(height: 18),
                        Text(
                          _error ?? 'Preparando el mapa 3D…',
                          textAlign: TextAlign.center,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _reintentar,
                            child: const Text('Reintentar'),
                          ),
                          TextButton(
                            onPressed:
                                widget.onBack ?? () => Navigator.pop(context),
                            child: const Text('Volver'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (back != null)
            Positioned(
              top: safeTop,
              left: 12,
              child: _control(
                Icons.arrow_back,
                widget.onBack != null ? 'Volver al inicio' : 'Volver',
                () async => back(),
              ),
            ),
          Positioned(
            top: safeTop,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _control(
                  Icons.search,
                  'Buscar una casa',
                  ready ? _buscar : null,
                ),
                const SizedBox(width: 8),
                _control(
                  Icons.view_in_ar,
                  _modo3d ? 'Ver mapa en 2D' : 'Ver mapa en 3D',
                  ready
                      ? () async {
                          setState(() => _modo3d = !_modo3d);
                          await _comando('modo', [_modo3d]);
                        }
                      : null,
                  label: _modo3d ? '2D' : '3D',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _control(
    IconData icon,
    String tooltip,
    Future<void> Function()? action, {
    String? label,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: SizedBox.square(
        dimension: 48,
        child: IconButton(
          tooltip: tooltip,
          onPressed: action,
          icon: label == null
              ? Icon(
                  icon,
                  color: action == null ? Colors.grey : const Color(0xFF344B40),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: action == null
                        ? Colors.grey
                        : const Color(0xFF344B40),
                  ),
                ),
        ),
      ),
    ),
  );
}

class _PuntaVentana extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close(),
    Paint()..color = Colors.white,
  );
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BuscadorCasas extends StatefulWidget {
  const _BuscadorCasas({required this.puntos});
  final List<PuntoMapa3D> puntos;
  @override
  State<_BuscadorCasas> createState() => _BuscadorCasasState();
}

class _BuscadorCasasState extends State<_BuscadorCasas> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtrados = widget.puntos
        .where(
          (p) => '${p.punto.nombre} ${p.punto.direccion}'
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: false,
                decoration: const InputDecoration(
                  labelText: 'Buscar una casa',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (text) => setState(() => query = text),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final punto = filtrados[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${punto.numero}')),
                    title: Text(punto.punto.nombre),
                    subtitle: Text(punto.punto.direccion),
                    onTap: () => Navigator.pop(context, punto),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
