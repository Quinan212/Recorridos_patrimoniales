import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componente_reproductor_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_mapa_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_dispositivo_admin.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_admin_fotos_punto.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componentes/imagen_universal.dart';

// -----------------------------------------------------------------------------
//  PANTALLA DE DETALLE DEL PUNTO PATRIMONIAL
// -----------------------------------------------------------------------------
class PantallaDetallePuntoAlejo extends StatefulWidget {
  final PuntoPatrimonial punto;

  const PantallaDetallePuntoAlejo({super.key, required this.punto});

  @override
  State<PantallaDetallePuntoAlejo> createState() =>
      _PantallaDetallePuntoAlejoState();
}

class _PantallaDetallePuntoAlejoState extends State<PantallaDetallePuntoAlejo> {
  final PageController _controladorCarrusel = PageController();
  late List<String> _urlsImagenes;
  late Future<EstadoDispositivoAdmin> _estadoAdminFuture;
  int _indiceImagenActual = 0;
  bool _subiendoFoto = false;
  bool _borrandoFoto = false;

  @override
  void initState() {
    super.initState();
    _urlsImagenes = List<String>.of(widget.punto.urlsImagenes);
    _estadoAdminFuture = const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
  }

  @override
  void dispose() {
    _controladorCarrusel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cantidadImagenes = _urlsImagenes.length;
    final anchoCacheCarrusel = (MediaQuery.sizeOf(context).width * 1.5).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: CustomScrollView(
        slivers: [
          // -- Header con carrusel ------------------------------------------
          SliverAppBar(
            expandedHeight: cantidadImagenes > 0 ? 310 : 120,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            automaticallyImplyLeading: false,
            // Botón atrás: glassmorphism, legible sobre cualquier fondo
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  cantidadImagenes > 0
                      ? _armarCarrusel(
                          context,
                          cantidadImagenes,
                          anchoCacheCarrusel,
                        )
                      : Container(
                          color: const Color(0xFF1A1A1A),
                          child: const Center(
                            child: _AlejoMark(size: 82, color: Colors.white24),
                          ),
                        ),
                  _armarAccionesFotoAdmin(),
                ],
              ),
            ),
          ),

          // -- Contenido ----------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    widget.punto.nombre,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Dirección
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.punto.direccion,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // Línea divisora roja
                  Container(
                    height: 3,
                    width: 48,
                    color: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 22),

                  // Descripción
                  if (widget.punto.descripcion.isNotEmpty) ...[
                    Text(
                      'DESCRIPCIÓN',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.punto.descripcion,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.7,
                        color: const Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Mapa miniatura
                  Text(
                    'UBICACIÓN',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _armarMiniMapa(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),

      // -- Botón reproducir audio --------------------------------------------
      bottomNavigationBar: _armarBarraAudio(context),
    );
  }

  // ---------------------------------------------------------------------
  //  CARRUSEL DE IMÁGENES con indicadores y toque para fullscreen
  // ---------------------------------------------------------------------
  Widget _armarCarrusel(BuildContext context, int cantidad, int anchoCache) {
    return Stack(
      children: [
        // Páginas de imágenes
        PageView.builder(
          controller: _controladorCarrusel,
          itemCount: cantidad,
          onPageChanged: (indice) =>
              setState(() => _indiceImagenActual = indice),
          itemBuilder: (context, indice) {
            final etiquetaHero = 'img_${widget.punto.id}_$indice';
            return GestureDetector(
              onTap: () => _abrirPantallaCompleta(context, indice),
              child: Hero(
                tag: etiquetaHero,
                child: ImagenUniversal(
                  url: _urlsImagenes[indice],
                  fit: BoxFit.cover,
                  anchoCache: anchoCache,
                  reemplazoVisual: Container(
                    color: const Color(0xFF222222),
                    child: const Center(
                      child: _AlejoMark(size: 62, color: Colors.white24),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Gradiente inferior (da profundidad y hace legibles los indicadores)
        // Usamos IgnorePointer para que los toques traspasen el gradiente
        // y lleguen a la imagen (permitiendo scrollear y abrir en pantalla completa).
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.55, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Contador "2 / 5" - arriba derecha
        if (cantidad > 1)
          Positioned(
            top: 12,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                '${_indiceImagenActual + 1} / $cantidad',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Indicadores de puntos - abajo centro
        if (cantidad > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cantidad, (indice) {
                final estaActivo = indice == _indiceImagenActual;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: estaActivo ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: estaActivo
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

        // Ícono expand - abajo derecha
        Positioned(
          bottom: 12,
          right: 14,
          child: GestureDetector(
            onTap: () => _abrirPantallaCompleta(context, _indiceImagenActual),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  //  ABRIR VISOR FULLSCREEN
  // ---------------------------------------------------------------------
  void _abrirPantallaCompleta(BuildContext context, int indiceInicial) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _VisorImagenPantallaCompleta(
              urlsImagenes: _urlsImagenes,
              indiceInicial: indiceInicial,
              idPunto: widget.punto.id,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // ---------------------------------------------------------------------
  //  MAPA MINIATURA
  // ---------------------------------------------------------------------
  Widget _armarAccionesFotoAdmin() {
    return FutureBuilder<EstadoDispositivoAdmin>(
      future: _estadoAdminFuture,
      builder: (context, instantanea) {
        final esAdmin = instantanea.data?.esAdmin == true;
        if (!esAdmin) return const SizedBox.shrink();

        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 14,
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_urlsImagenes.isNotEmpty) ...[
                  _BotonAccionFotoAdmin(
                    tooltip: 'Borrar foto',
                    onTap: _subiendoFoto || _borrandoFoto
                        ? null
                        : _manejarBorradoFotoAdmin,
                    child: _borrandoFoto
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                  const SizedBox(width: 8),
                ],
                _BotonAccionFotoAdmin(
                  tooltip: 'Agregar foto',
                  onTap: _subiendoFoto || _borrandoFoto
                      ? null
                      : _manejarSubidaFotoAdmin,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_subiendoFoto)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        const SizedBox(width: 7),
                        Text(
                          _subiendoFoto ? 'Subiendo' : 'Foto',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _manejarSubidaFotoAdmin() async {
    setState(() => _subiendoFoto = true);

    try {
      final urlPublica = await const ServicioAdminFotosPunto().subirFotoPunto(
        punto: widget.punto,
        orden: _urlsImagenes.length,
      );

      if (!mounted) return;
      setState(() {
        _urlsImagenes = [..._urlsImagenes, urlPublica];
        _indiceImagenActual = _urlsImagenes.length - 1;
      });
      await context.read<RepositorioPatrimonio>().cargar();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto agregada al punto')));
    } on CargaFotoCancelada {
      // El usuario cerro el selector sin elegir imagen.
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo subir la foto: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _subiendoFoto = false);
      }
    }
  }

  Future<void> _manejarBorradoFotoAdmin() async {
    if (_urlsImagenes.isEmpty) return;

    final urlImagen = _urlsImagenes[_indiceImagenActual];
    final debeBorrar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar foto'),
        content: const Text('Esta foto se va a quitar del punto.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (debeBorrar != true || !mounted) return;
    setState(() => _borrandoFoto = true);

    try {
      await const ServicioAdminFotosPunto().borrarFotoPunto(
        punto: widget.punto,
        urlImagen: urlImagen,
      );

      if (!mounted) return;
      setState(() {
        _urlsImagenes = [
          for (final url in _urlsImagenes)
            if (url != urlImagen) url,
        ];
        if (_indiceImagenActual >= _urlsImagenes.length) {
          _indiceImagenActual = _urlsImagenes.isEmpty
              ? 0
              : _urlsImagenes.length - 1;
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            _urlsImagenes.isEmpty ||
            !_controladorCarrusel.hasClients) {
          return;
        }
        _controladorCarrusel.jumpToPage(_indiceImagenActual);
      });

      await context.read<RepositorioPatrimonio>().cargar();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto borrada del punto')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo borrar la foto: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _borrandoFoto = false);
      }
    }
  }

  Widget _armarMiniMapa(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaMapaAlejo(idPuntoInicial: widget.punto.id),
        ),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.punto.lat, widget.punto.lng),
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'ar.maillet.recorridos_patrimoniales',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.punto.lat, widget.punto.lng),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: _AlejoMark(size: 21, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Overlay con hint
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Ver en mapa',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  //  BARRA DE AUDIO INFERIOR
  // ---------------------------------------------------------------------
  Widget _armarBarraAudio(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(color: Colors.white),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (widget.punto.urlAudio != null &&
                widget.punto.urlAudio!.isNotEmpty) {
              reproducirAudioGlobal(
                context,
                widget.punto.nombre,
                widget.punto.urlAudio!,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audio no disponible para este punto'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.headphones, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'REPRODUCIR AUDIO',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonAccionFotoAdmin extends StatelessWidget {
  final String tooltip;
  final VoidCallback? onTap;
  final Widget child;

  const _BotonAccionFotoAdmin({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AlejoMark extends StatelessWidget {
  const _AlejoMark({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'A',
      style: GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        fontStyle: FontStyle.italic,
        height: 1,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  VISOR FULLSCREEN DE IMÁGENES
//  -- Hero animation desde el carrusel
//  -- Deslizar entre fotos (PageView)
//  -- Pinch-to-zoom en cada imagen (InteractiveViewer)
//  -- Swipe vertical para cerrar
// -----------------------------------------------------------------------------
class _VisorImagenPantallaCompleta extends StatefulWidget {
  final List<String> urlsImagenes;
  final int indiceInicial;
  final String idPunto;

  const _VisorImagenPantallaCompleta({
    required this.urlsImagenes,
    required this.indiceInicial,
    required this.idPunto,
  });

  @override
  State<_VisorImagenPantallaCompleta> createState() =>
      _VisorImagenPantallaCompletaState();
}

class _VisorImagenPantallaCompletaState
    extends State<_VisorImagenPantallaCompleta> {
  late final PageController _controladorPagina;
  late int _indiceActual;
  bool _mostrarInterfaz = true;

  @override
  void initState() {
    super.initState();
    _indiceActual = widget.indiceInicial;
    _controladorPagina = PageController(initialPage: widget.indiceInicial);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _controladorPagina.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _mostrarInterfaz = !_mostrarInterfaz),
        child: Stack(
          children: [
            // -- Páginas de imágenes con zoom --
            PageView.builder(
              controller: _controladorPagina,
              itemCount: widget.urlsImagenes.length,
              onPageChanged: (indice) => setState(() => _indiceActual = indice),
              itemBuilder: (context, indice) {
                final etiquetaHero = 'img_${widget.idPunto}_$indice';
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  panEnabled: true,
                  child: Center(
                    child: Hero(
                      tag: etiquetaHero,
                      child: ImagenUniversal(
                        url: widget.urlsImagenes[indice],
                        fit: BoxFit.contain,
                        anchoCache: (MediaQuery.sizeOf(context).width * 2)
                            .round(),
                        reemplazoVisual: const Icon(
                          Icons.broken_image,
                          color: Colors.white30,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // -- UI superpuesta (se oculta al tocar) --
            AnimatedOpacity(
              opacity: _mostrarInterfaz ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  // Gradiente superior
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Botón cerrar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Contador
                            if (widget.urlsImagenes.length > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_indiceActual + 1} / ${widget.urlsImagenes.length}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(),
                            // X cerrar
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Indicadores de puntos inferiores
                  if (widget.urlsImagenes.length > 1)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.urlsImagenes.length, (
                            indice,
                          ) {
                            final estaActivo = indice == _indiceActual;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: estaActivo ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: estaActivo
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
