import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:recorridos_patrimoniales/datos/datos_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componentes/imagen_universal.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_admin_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_dispositivo_admin.dart';

class PantallaDetallePublicacion extends StatefulWidget {
  final Publicacion publicacion;

  const PantallaDetallePublicacion({super.key, required this.publicacion});

  @override
  State<PantallaDetallePublicacion> createState() =>
      _PantallaDetallePublicacionState();
}

class _PantallaDetallePublicacionState
    extends State<PantallaDetallePublicacion> {
  final PageController _controladorCarrusel = PageController();
  late List<String> _urlsImagenes;
  late Future<EstadoDispositivoAdmin> _estadoAdminFuture;
  int _indiceImagenActual = 0;
  bool _subiendoFoto = false;
  bool _borrandoFoto = false;

  @override
  void initState() {
    super.initState();
    _urlsImagenes = List<String>.of(widget.publicacion.urlsImagenes);
    _estadoAdminFuture =
        const ServicioDispositivoAdmin().verificarDispositivoActual();
  }

  @override
  void dispose() {
    _controladorCarrusel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cantidadImagenes = _urlsImagenes.length;
    final fechaTexto = _formatearFecha(widget.publicacion.fechaEvento);
    final anchoCacheCarrusel =
        (MediaQuery.sizeOf(context).width * 1.5).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: SafeArea(
        top: true,
        bottom: true,
        child: CustomScrollView(
        slivers: [
          // -- HEADER CON CARRUSEL -----------------------------------------
          SliverAppBar(
            expandedHeight: cantidadImagenes > 0 ? 310 : 120,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: _compartirPublicacion,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                          child: Center(
                            child: Text(
                              widget.publicacion.titulo[0],
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 82,
                                fontWeight: FontWeight.w900,
                                color: Colors.white24,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                  _armarAccionesAdmin(),
                ],
              ),
            ),
          ),

          // -- CONTENIDO ----------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Evento + Fecha
                  if (widget.publicacion.nombreEvento.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.publicacion.nombreEvento,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Titulo
                  Text(
                    widget.publicacion.titulo,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Fecha
                  if (fechaTexto.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Color(0xFFD32F2F),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          fechaTexto,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 22),

                  // Linea divisora roja
                  Container(
                    height: 3,
                    width: 48,
                    color: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 22),

                  // Descripcion completa
                  if (widget.publicacion.descripcion.isNotEmpty) ...[
                    Text(
                      'DETALLES',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.publicacion.descripcion,
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.7,
                        color: const Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Galeria completa si hay mas fotos
                  if (_urlsImagenes.length > 1) ...[
                    Text(
                      'GALERIA',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _armarGaleriaMiniaturas(),
                    const SizedBox(height: 28),
                  ],

                  // Seccion de contacto
                  _armarSeccionContacto(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // =========================================================================
  //  CARRUSEL DE IMAGENES
  // =========================================================================
  Widget _armarCarrusel(BuildContext context, int cantidad, int anchoCache) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controladorCarrusel,
          itemCount: cantidad,
          onPageChanged: (indice) =>
              setState(() => _indiceImagenActual = indice),
          itemBuilder: (context, indice) {
            return GestureDetector(
              onTap: () => _abrirPantallaCompleta(context, indice),
              child: ImagenUniversal(
                url: _urlsImagenes[indice],
                fit: BoxFit.cover,
                anchoCache: anchoCache,
                reemplazoVisual: Container(
                  color: const Color(0xFF222222),
                  child: Center(
                    child: Text(
                      widget.publicacion.titulo[0],
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 62,
                        fontWeight: FontWeight.w900,
                        color: Colors.white24,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Gradiente inferior
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
        // Contador arriba derecha
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
        // Indicadores abajo centro
        if (cantidad > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cantidad, (indice) {
                final activo = indice == _indiceImagenActual;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: activo ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: activo
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        // Icono expand abajo derecha
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

  // =========================================================================
  //  GALERIA DE MINIATURAS (debajo de la descripcion)
  // =========================================================================
  Widget _armarGaleriaMiniaturas() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _urlsImagenes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, indice) {
          final activo = indice == _indiceImagenActual;

          return GestureDetector(
            onTap: () => _abrirPantallaCompleta(context, indice),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: activo ? 160 : 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: activo
                    ? Border.all(color: const Color(0xFFD32F2F), width: 2)
                    : null,
                boxShadow: activo
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: ImagenUniversal(
                url: _urlsImagenes[indice],
                fit: BoxFit.cover,
                anchoCache: 200,
                reemplazoVisual: Container(
                  color: const Color(0xFF222222),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  //  ACCIONES ADMIN
  // =========================================================================
  Widget _armarAccionesAdmin() {
    return FutureBuilder<EstadoDispositivoAdmin>(
      future: _estadoAdminFuture,
      builder: (context, snapshot) {
        final esAdmin = snapshot.data?.esAdmin == true;
        if (!esAdmin) return const SizedBox.shrink();

        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 14,
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_urlsImagenes.isNotEmpty) ...[
                  _BotonAdmin(
                    tooltip: 'Borrar foto',
                    onTap: _subiendoFoto || _borrandoFoto
                        ? null
                        : _manejarBorradoFoto,
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
                _BotonAdmin(
                  tooltip: 'Agregar foto',
                  onTap: _subiendoFoto || _borrandoFoto
                      ? null
                      : _manejarSubidaFoto,
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

  Future<void> _manejarSubidaFoto() async {
    setState(() => _subiendoFoto = true);
    try {
      await const ServicioAdminPublicaciones().subirImagen(
        publicationId: widget.publicacion.id,
        orden: _urlsImagenes.length,
      );
      if (!mounted) return;
      // Recargar desde Supabase para obtener la URL
      await context.read<RepositorioPublicaciones>().cargar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto agregada a la publicacion')),
      );
    } on CargaFotoPublicacionCancelada {
      // Usuario cerro el selector
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo subir la foto: $error')),
      );
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _manejarBorradoFoto() async {
    if (_urlsImagenes.isEmpty || _indiceImagenActual >= _urlsImagenes.length) {
      return;
    }

    final urlImagen = _urlsImagenes[_indiceImagenActual];
    final debeBorrar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar foto'),
        content: const Text('Esta foto se va a quitar de la publicacion.'),
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

    // Extraer storage_path de la URL publica
    final marcador = '/storage/v1/object/public/publication-images/';
    final indice = urlImagen.indexOf(marcador);
    if (indice == -1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar la foto remota')),
      );
      return;
    }

    final rutaStorage = Uri.decodeFull(
      urlImagen.substring(indice + marcador.length).split('?').first,
    );

    setState(() => _borrandoFoto = true);
    try {
      await const ServicioAdminPublicaciones().borrarImagen(
        publicationId: widget.publicacion.id,
        storagePath: rutaStorage,
      );
      if (!mounted) return;
      setState(() {
        _urlsImagenes = [
          for (final url in _urlsImagenes)
            if (url != urlImagen) url,
        ];
        if (_indiceImagenActual >= _urlsImagenes.length) {
          _indiceImagenActual =
              _urlsImagenes.isEmpty ? 0 : _urlsImagenes.length - 1;
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto borrada de la publicacion')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo borrar la foto: $error')),
      );
    } finally {
      if (mounted) setState(() => _borrandoFoto = false);
    }
  }

  // =========================================================================
  //  VISOR FULLSCREEN
  // =========================================================================
  void _abrirPantallaCompleta(BuildContext context, int indiceInicial) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _VisorPublicacionFullscreen(
          urlsImagenes: _urlsImagenes,
          indiceInicial: indiceInicial,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // =========================================================================
  //  SECCION DE CONTACTO / DIVULGACION (con enlaces reales)
  // =========================================================================
  Widget _armarSeccionContacto(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.volunteer_activism_outlined,
                  color: Color(0xFFD32F2F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¿Queres que visitemos tu institucion?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Recorridos Patrimoniales participa en ferias, escuelas, '
            'fundaciones, universidades y eventos culturales. '
            'Si te interesa que presentemos el proyecto en tu '
            'institucion, contactanos por cualquiera de estos medios.',
            textAlign: TextAlign.justify,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),

          // -- Email Alan --
          _BotonContactoReal(
            icon: Icons.email_outlined,
            label: 'Alan Gabriel Maillet',
            subtitle: 'alanmaillet51@gmail.com',
            color: const Color(0xFFEA4335),
            onTap: () => _lanzarUrl('mailto:alanmaillet51@gmail.com'),
          ),
          const SizedBox(height: 10),

          // -- Email Flavia --
          _BotonContactoReal(
            icon: Icons.email_outlined,
            label: 'Flavia Marisol Frigo',
            subtitle: 'frigoflavia4@gmail.com',
            color: const Color(0xFFEA4335),
            onTap: () => _lanzarUrl('mailto:frigoflavia4@gmail.com'),
          ),
          const SizedBox(height: 10),

          // -- Instagram --
          _BotonContactoReal(
            icon: Icons.camera_alt_outlined,
            label: 'Instagram',
            subtitle: '@maillet.alan',
            color: const Color(0xFFE4405F),
            onTap: () => _lanzarUrl('https://instagram.com/maillet.alan'),
          ),
          const SizedBox(height: 10),

          // -- WhatsApp --
          _BotonContactoReal(
            icon: Icons.chat_outlined,
            label: 'WhatsApp',
            subtitle: 'Escribinos al WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () => _lanzarUrl('https://wa.me/543454105261'),
          ),
          const SizedBox(height: 16),

          // -- Compartir --
          OutlinedButton.icon(
            onPressed: _compartirPublicacion,
            icon: const Icon(Icons.share, size: 18),
            label: Text('Compartir esta publicacion'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A1A1A),
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _lanzarUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir: $e')),
      );
    }
  }

  Future<void> _compartirPublicacion() async {
    final texto = [
      '📢 ${widget.publicacion.titulo}',
      '',
      if (widget.publicacion.nombreEvento.isNotEmpty)
        '📍 ${widget.publicacion.nombreEvento}',
      if (widget.publicacion.fechaEvento != null)
        '📅 ${_formatearFecha(widget.publicacion.fechaEvento)}',
      '',
      widget.publicacion.descripcion.replaceAll(RegExp(r'\n+'), ' '),
      '',
      'Descarga Recorridos Patrimoniales y descubri la obra de Alejo Martinez en Concordia.',
    ].join('\n');

    if (widget.publicacion.urlsImagenes.isNotEmpty) {
      await SharePlus.instance.share(
        ShareParams(text: texto),
      );
    } else {
      await SharePlus.instance.share(
        ShareParams(text: texto),
      );
    }
  }

  // =========================================================================
  //  HELPERS
  // =========================================================================
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return DateFormat('MMMM yyyy', 'es').format(fecha);
  }
}

// =============================================================================
//  BOTON ADMIN
// =============================================================================
class _BotonAdmin extends StatelessWidget {
  final String tooltip;
  final VoidCallback? onTap;
  final Widget child;

  const _BotonAdmin({
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

// =============================================================================
//  BOTON DE CONTACTO REAL con icono, label y subtitulo
// =============================================================================
class _BotonContactoReal extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _BotonContactoReal({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  VISOR FULLSCREEN
// =============================================================================
class _VisorPublicacionFullscreen extends StatefulWidget {
  final List<String> urlsImagenes;
  final int indiceInicial;

  const _VisorPublicacionFullscreen({
    required this.urlsImagenes,
    required this.indiceInicial,
  });

  @override
  State<_VisorPublicacionFullscreen> createState() =>
      _VisorPublicacionFullscreenState();
}

class _VisorPublicacionFullscreenState
    extends State<_VisorPublicacionFullscreen> {
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
            PageView.builder(
              controller: _controladorPagina,
              itemCount: widget.urlsImagenes.length,
              onPageChanged: (i) => setState(() => _indiceActual = i),
              itemBuilder: (context, indice) {
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  panEnabled: true,
                  child: Center(
                    child: ImagenUniversal(
                      url: widget.urlsImagenes[indice],
                      fit: BoxFit.contain,
                      anchoCache:
                          (MediaQuery.sizeOf(context).width * 2).round(),
                      reemplazoVisual: const Icon(
                        Icons.broken_image,
                        color: Colors.white30,
                        size: 80,
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedOpacity(
              opacity: _mostrarInterfaz ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  Positioned(
                    top: 0, left: 0, right: 0, height: 100,
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
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.urlsImagenes.length > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6,
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
                  if (widget.urlsImagenes.length > 1)
                    Positioned(
                      bottom: 30, left: 0, right: 0,
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.urlsImagenes.length, (
                            indice,
                          ) {
                            final activo = indice == _indiceActual;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: activo ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: activo
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
