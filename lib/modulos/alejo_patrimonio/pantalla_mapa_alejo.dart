import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_punto_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componente_reproductor_audio.dart'
    show reproducirAudioGlobal, ControladorAudio;
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componentes/imagen_universal.dart';

class PantallaMapaAlejo extends StatefulWidget {
  final String? idPuntoInicial;
  final VoidCallback? onBack;

  const PantallaMapaAlejo({super.key, this.idPuntoInicial, this.onBack});

  @override
  State<PantallaMapaAlejo> createState() => _PantallaMapaAlejoState();
}

class _PantallaMapaAlejoState extends State<PantallaMapaAlejo> {
  final MapController _mapController = MapController();
  final ValueNotifier<MapCamera?> _viewportNotifier = ValueNotifier(null);
  List<PuntoPatrimonial> _puntosActuales = puntosAlejo;
  PuntoPatrimonial? _puntoSeleccionado;
  Timer? _ubicacionTimer;
  LatLng? _ubicacionUsuario;
  static const double _labelZoomThreshold = 17.2;
  static const int _clusterDisableZoom = 16;
  static const double _minZoom = 12.0;
  static const double _maxZoom = 18.0;
  static const double _zoomStep = 0.65;

  LatLng _centroInicialPara(List<PuntoPatrimonial> puntos) {
    if (widget.idPuntoInicial != null) {
      final punto = puntos.firstWhere(
        (p) => p.id == widget.idPuntoInicial,
        orElse: () => puntos.first,
      );
      return LatLng(punto.lat, punto.lng);
    }
    return const LatLng(-31.378, -58.040);
  }

  double get _initialZoom => widget.idPuntoInicial != null ? 16.0 : 13.0;

  @override
  void initState() {
    super.initState();
    if (widget.idPuntoInicial != null) {
      _puntoSeleccionado = _puntosActuales.firstWhere(
        (p) => p.id == widget.idPuntoInicial,
        orElse: () => _puntosActuales.first,
      );
    }
    _startLocationTracking();
  }

  @override
  void dispose() {
    _ubicacionTimer?.cancel();
    _viewportNotifier.dispose();
    super.dispose();
  }

  double _calcularDistancia(PuntoPatrimonial punto) {
    final ubicacionUsuario = _ubicacionUsuario;
    if (ubicacionUsuario == null) {
      const userLat = -31.392;
      const userLng = -58.020;
      const distanciaEnMetros = Distance();
      return distanciaEnMetros.as(
        LengthUnit.Meter,
        LatLng(userLat, userLng),
        LatLng(punto.lat, punto.lng),
      );
    }

    const distanciaEnMetros = Distance();
    return distanciaEnMetros.as(
      LengthUnit.Meter,
      ubicacionUsuario,
      LatLng(punto.lat, punto.lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneAudio = context.select(
      (ControladorAudio audio) => audio.tieneAudio,
    );
    final puntos = context.watch<RepositorioPatrimonio>().puntos;
    _puntosActuales = puntos;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    final cardBottom = (tieneAudio ? 120.0 : 16.0) + bottomPadding;
    final barBottom = (tieneAudio ? 120.0 : 16.0) + bottomPadding;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centroInicialPara(puntos),
              initialZoom: _initialZoom,
              maxZoom: _maxZoom,
              minZoom: _minZoom,
              onPositionChanged: _manejarCambioPosicion,
              onTap: (tapPosition, latLng) {
                setState(() => _puntoSeleccionado = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'ar.maillet.recorridos_patrimoniales',
                tileProvider: NetworkTileProvider(
                  cachingProvider:
                      BuiltInMapCachingProvider.getOrCreateInstance(
                        maxCacheSize: 250000000,
                      ),
                ),
                keepBuffer: 1,
                panBuffer: 0,
                tileDisplay: const TileDisplay.instantaneous(),
              ),
              ValueListenableBuilder<MapCamera?>(
                valueListenable: _viewportNotifier,
                builder: (context, viewport, _) {
                  final zoom = viewport?.zoom ?? _initialZoom;
                  final mostrarEtiquetas = zoom >= _labelZoomThreshold;
                  final usarMiniaturas = zoom >= 17.0;
                  final puntosVisibles = _puntosVisibles(
                    viewport?.visibleBounds,
                  );
                  final marcadors = _armarMarcadors(
                    puntosVisibles,
                    mostrarEtiquetas: mostrarEtiquetas,
                    usarMiniaturas: usarMiniaturas,
                  );

                  return Stack(
                    children: [
                      MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          markers: marcadors,
                          builder: _armarMarcadorCluster,
                          maxClusterRadius: 60,
                          size: const Size(38, 38),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(48),
                          maxZoom: 18,
                          disableClusteringAtZoom: _clusterDisableZoom,
                          zoomToBoundsOnClick: true,
                          centerMarkerOnClick: false,
                          spiderfyCluster: false,
                          showPolygon: false,
                          rotate: true,
                          animationsOptions: const AnimationsOptions(
                            zoom: Duration(milliseconds: 180),
                            fitBound: Duration(milliseconds: 180),
                            centerMarker: Duration(milliseconds: 120),
                            spiderfy: Duration(milliseconds: 0),
                          ),
                          onMarkerTap: _manejarToqueMarcador,
                        ),
                      ),
                      if (_ubicacionUsuario != null)
                        MarkerLayer(
                          markers: [
                            _armarMarcadorUbicacionUsuario(_ubicacionUsuario!),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ],
          ),

          // Flecha atras (10px debajo del Status Bar)
          Positioned(
            top: topPadding + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!.call();
                    return;
                  }

                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),

          // Barra inferior - solo cuando no hay punto seleccionado
          Positioned(
            top: topPadding + 74,
            right: 20,
            child: _armarControlesZoom(),
          ),

          if (_puntoSeleccionado == null)
            Positioned(
              bottom: barBottom,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const _AlejoMark(size: 22, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ALEJO MARTINEZ',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Recorrido de la Innovacion',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Tarjeta flotante del punto seleccionado
          if (_puntoSeleccionado != null)
            Positioned(
              bottom: cardBottom,
              left: 16,
              right: 16,
              child: _armarTarjetaPunto(_puntoSeleccionado!),
            ),
        ],
      ),
    );
  }

  // -----------------------------------------
  //  MARCADOR en el mapa
  // -----------------------------------------
  // ignore: unused_element
  Widget _armarMarcador(
    PuntoPatrimonial punto,
    bool estaSeleccionado,
    bool mostrarEtiqueta,
  ) {
    Widget nucleoMarcador;
    if (estaSeleccionado) {
      nucleoMarcador = SizedBox(
        width: 65,
        height: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD32F2F), width: 3.5),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
    } else {
      nucleoMarcador = Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[400]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: punto.urlsImagenes.isNotEmpty
              ? ImagenUniversal(
                  url: punto.urlsImagenes.first,
                  fit: BoxFit.cover,
                  width: 41,
                  height: 41,
                  anchoCache: 100,
                  reemplazoVisual: _armarPlaceholder(),
                )
              : _armarPlaceholder(),
        ),
      );
    }

    if (!mostrarEtiqueta) return nucleoMarcador;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        nucleoMarcador,
        Positioned(
          left: estaSeleccionado ? 60 : 50,
          top: estaSeleccionado ? 12 : 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              punto.nombre,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _armarPlaceholder() {
    return Container(
      width: 41,
      height: 41,
      color: Colors.grey[200],
      child: const Center(child: _AlejoMark(size: 25)),
    );
  }

  // -----------------------------------------
  //  TARJETA del punto seleccionado
  // -----------------------------------------
  void _manejarCambioPosicion(MapCamera camera, bool hasGesture) {
    final current = _viewportNotifier.value;
    if (current == camera) {
      return;
    }
    _viewportNotifier.value = camera;
  }

  void _zoomBy(double delta) {
    final camera = _viewportNotifier.value;
    final center = camera?.center ?? _centroInicialPara(_puntosActuales);
    final zoom = camera?.zoom ?? _initialZoom;
    final nextZoom = (zoom + delta).clamp(_minZoom, _maxZoom).toDouble();

    if ((nextZoom - zoom).abs() < 0.01) return;
    _mapController.move(center, nextZoom);
  }

  Widget _armarControlesZoom() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _armarBotonZoom(
            icon: Icons.add,
            tooltip: 'Acercar',
            onPressed: () => _zoomBy(_zoomStep),
          ),
          Container(width: 32, height: 1, color: const Color(0xFFE6E6E6)),
          _armarBotonZoom(
            icon: Icons.remove,
            tooltip: 'Alejar',
            onPressed: () => _zoomBy(-_zoomStep),
          ),
        ],
      ),
    );
  }

  Widget _armarBotonZoom({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 44,
      height: 42,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
        padding: EdgeInsets.zero,
        splashRadius: 22,
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _startLocationTracking() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      await _updateUserLocation();
      _ubicacionTimer?.cancel();
      _ubicacionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _updateUserLocation();
      });
    } catch (_) {
      // Keep the map usable even if ubicacion fails.
    }
  }

  Future<void> _updateUserLocation() async {
    try {
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _ubicacionUsuario = LatLng(posicion.latitude, posicion.longitude);
      });
    } catch (_) {
      // Ignore transient ubicacion failures.
    }
  }

  Marker _armarMarcadorUbicacionUsuario(LatLng ubicacion) {
    return Marker(
      point: ubicacion,
      width: 34,
      height: 34,
      alignment: Alignment.center,
      child: RepaintBoundary(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<PuntoPatrimonial> _puntosVisibles(LatLngBounds? limites) {
    final seleccionado = _puntoSeleccionado;

    if (limites == null) {
      return _puntosActuales.toList(growable: seleccionado != null);
    }

    final limitesAmpliados = _expandBounds(limites, 0.25);
    final puntosVisibles = _puntosActuales
        .where(
          (punto) => limitesAmpliados.contains(LatLng(punto.lat, punto.lng)),
        )
        .toList(growable: true);

    if (seleccionado != null &&
        !puntosVisibles.any((punto) => punto.id == seleccionado.id)) {
      puntosVisibles.add(seleccionado);
    }

    return puntosVisibles;
  }

  LatLngBounds _expandBounds(LatLngBounds limites, double factor) {
    final latPadding = (limites.north - limites.south).abs() * factor;
    final lonPadding = (limites.east - limites.west).abs() * factor;

    return LatLngBounds.unsafe(
      north: (limites.north + latPadding).clamp(-90.0, 90.0),
      south: (limites.south - latPadding).clamp(-90.0, 90.0),
      east: (limites.east + lonPadding).clamp(-180.0, 180.0),
      west: (limites.west - lonPadding).clamp(-180.0, 180.0),
    );
  }

  List<Marker> _armarMarcadors(
    List<PuntoPatrimonial> puntos, {
    required bool mostrarEtiquetas,
    required bool usarMiniaturas,
  }) {
    return puntos
        .map(
          (punto) => Marker(
            key: ValueKey(punto.id),
            point: LatLng(punto.lat, punto.lng),
            width: _marcadorSize(
              estaSeleccionado: punto.id == _puntoSeleccionado?.id,
              usarMiniaturas: usarMiniaturas,
            ),
            height: _marcadorSize(
              estaSeleccionado: punto.id == _puntoSeleccionado?.id,
              usarMiniaturas: usarMiniaturas,
            ),
            child: _armarVisualMarcador(
              punto,
              estaSeleccionado: punto.id == _puntoSeleccionado?.id,
              mostrarEtiqueta: mostrarEtiquetas,
              usarMiniatura: usarMiniaturas,
            ),
            rotate: true,
          ),
        )
        .toList(growable: false);
  }

  double _marcadorSize({
    required bool estaSeleccionado,
    required bool usarMiniaturas,
  }) {
    if (usarMiniaturas) {
      return estaSeleccionado ? 54.0 : 42.0;
    }
    return estaSeleccionado ? 38.0 : 30.0;
  }

  Widget _armarVisualMarcador(
    PuntoPatrimonial punto, {
    required bool estaSeleccionado,
    required bool mostrarEtiqueta,
    required bool usarMiniatura,
  }) {
    final nucleoMarcador = usarMiniatura
        ? _armarMarcadorMiniatura(punto, estaSeleccionado)
        : _armarMarcadorCompacto(estaSeleccionado);

    if (!mostrarEtiqueta) return nucleoMarcador;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        nucleoMarcador,
        Positioned(
          left: estaSeleccionado ? 58 : 48,
          top: estaSeleccionado ? 10 : 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              punto.nombre,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _armarMarcadorCompacto(bool estaSeleccionado) {
    final size = estaSeleccionado ? 38.0 : 30.0;

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: estaSeleccionado
                ? const Color(0xFFD32F2F).withValues(alpha: 0.14)
                : Colors.white,
            border: Border.all(
              color: estaSeleccionado
                  ? const Color(0xFFD32F2F)
                  : Colors.grey[350]!,
              width: estaSeleccionado ? 2.5 : 1.4,
            ),
          ),
          child: Center(
            child: Icon(
              estaSeleccionado ? Icons.place : Icons.location_on_outlined,
              color: estaSeleccionado
                  ? const Color(0xFFD32F2F)
                  : Colors.grey[600],
              size: estaSeleccionado ? 19 : 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _armarMarcadorMiniatura(
    PuntoPatrimonial punto,
    bool estaSeleccionado,
  ) {
    final ringColor = estaSeleccionado ? const Color(0xFFD32F2F) : Colors.white;
    final size = estaSeleccionado ? 54.0 : 42.0;

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: ringColor,
              width: estaSeleccionado ? 3 : 2,
            ),
          ),
          child: ClipOval(
            child: punto.urlsImagenes.isNotEmpty
                ? SizedBox.expand(
                    child: ImagenUniversal(
                      url: punto.urlsImagenes.first,
                      fit: BoxFit.cover,
                      anchoCache: 96,
                      altoCache: 96,
                      reemplazoVisual: _armarPlaceholderMiniatura(),
                    ),
                  )
                : _armarPlaceholderMiniatura(),
          ),
        ),
      ),
    );
  }

  Widget _armarPlaceholderMiniatura() {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.grey[200]!,
        child: const Center(child: _AlejoMark(size: 22)),
      ),
    );
  }

  void _manejarToqueMarcador(Marker marcador) {
    final puntoTocado = _puntoParaMarcador(marcador);
    if (puntoTocado == null) return;

    setState(() {
      _puntoSeleccionado = puntoTocado;
    });
  }

  PuntoPatrimonial? _puntoParaMarcador(Marker marcador) {
    final claveMarcador = marcador.key;
    if (claveMarcador is ValueKey<String>) {
      for (final punto in _puntosActuales) {
        if (punto.id == claveMarcador.value) return punto;
      }
    }

    for (final punto in _puntosActuales) {
      if (punto.lat == marcador.point.latitude &&
          punto.lng == marcador.point.longitude) {
        return punto;
      }
    }
    return null;
  }

  Widget _armarMarcadorCluster(BuildContext context, List<Marker> marcadors) {
    return RepaintBoundary(
      child: SizedBox(
        width: 38,
        height: 38,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD32F2F), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              marcadors.length.toString(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _armarTarjetaPunto(PuntoPatrimonial punto) {
    final distanciaEnMetros = _calcularDistancia(punto);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaDetallePuntoAlejo(punto: punto),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 90),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // -- Foto: cuadrado propio con bordes redondeados y margen --
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: punto.urlsImagenes.isNotEmpty
                      ? ImagenUniversal(
                          url: punto.urlsImagenes.first,
                          fit: BoxFit.cover,
                          anchoCache: 100,
                          reemplazoVisual: Container(
                            color: const Color(0xFFEEEEEE),
                            child: const Center(child: _AlejoMark(size: 30)),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFEEEEEE),
                          child: const Center(child: _AlejoMark(size: 30)),
                        ),
                ),
              ),
            ),

            // -- Nombre + distancia --
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    punto.nombre,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.navigation,
                        size: 13,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${distanciaEnMetros.round()} m',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // -- Boton play circular --
            GestureDetector(
              onTap: () {
                if (punto.urlAudio != null && punto.urlAudio!.isNotEmpty) {
                  reproducirAudioGlobal(context, punto.nombre, punto.urlAudio!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio no disponible para este punto'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlejoMark extends StatelessWidget {
  const _AlejoMark({required this.size, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'A',
      style: GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? Colors.grey[600],
        fontStyle: FontStyle.italic,
        height: 1,
      ),
    );
  }
}
