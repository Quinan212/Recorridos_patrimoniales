import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/datos/datos_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_publicacion.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_formulario_publicacion.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_dispositivo_admin.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componentes/imagen_universal.dart';

class PantallaPublicaciones extends StatefulWidget {
  const PantallaPublicaciones({super.key});

  @override
  State<PantallaPublicaciones> createState() => _PantallaPublicacionesState();
}

class _PantallaPublicacionesState extends State<PantallaPublicaciones> {
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  Future<void> _verificarAdmin() async {
    final estado = await const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
    if (!mounted) return;
    setState(() {
      _esAdmin = estado.esAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final publicaciones = context
        .watch<RepositorioPublicaciones>()
        .publicaciones;
    final mediaQuery = MediaQuery.of(context);
    final usableHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CustomScrollView(
            clipBehavior: Clip.hardEdge,
            slivers: [
              // -- HEADER EDITORIAL --
              SliverToBoxAdapter(
                child: _HeaderPublicaciones(usableHeight: usableHeight),
              ),

              // -- DESCRIPCION DE LA SECCION --
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Text(
                    'Compartimos nuestro trabajo en ferias, universidades, '
                    'fundaciones e instituciones. Cada publicacion documenta '
                    'una presentación, sus fotos y el intercambio generado.',
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              // -- LINEA DE TIEMPO DE PUBLICACIONES --
              if (publicaciones.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Todavia no hay publicaciones',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _TarjetaPublicacion(
                      publicacion: publicaciones[index],
                      esUltima: index == publicaciones.length - 1,
                    );
                  }, childCount: publicaciones.length),
                ),

              // Espacio inferior
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
      floatingActionButton: _esAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaFormularioPublicacion(),
                  ),
                );
              },
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'Nueva',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
  }
}

// =============================================================================
//  HEADER (robusto: sin Spacer, sin overflow)
// =============================================================================
class _HeaderPublicaciones extends StatelessWidget {
  final double usableHeight;

  const _HeaderPublicaciones({required this.usableHeight});

  @override
  Widget build(BuildContext context) {
    final coverHeight = (usableHeight * 0.28).clamp(180.0, 280.0).toDouble();

    return SizedBox(
      height: coverHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Circulos decorativos de fondo
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD32F2F).withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Gradiente suave
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF5F5F3).withValues(alpha: 0.85),
                    const Color(0xFFF5F5F3),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Contenido: scrolleable interno para no reventar nunca
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Si hay suficiente espacio, centramos vertical
                    // Si no, el SingleChildScrollView salva el overflow
                    if (constraints.maxHeight > 260) {
                      return _HeaderContent();
                    }
                    return SingleChildScrollView(child: _HeaderContent());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenido real del header, reusable para scroll o layout fijo
class _HeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label "SECCION"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'DIVULGACION',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
              color: const Color(0xFFD32F2F),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Publicaciones\ny Eventos',
            style: GoogleFonts.playfairDisplay(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              height: 0.95,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(height: 4, width: 44, color: const Color(0xFFD32F2F)),
        const SizedBox(height: 8),
        Text(
          'COMPARTIENDO NUESTRO TRABAJO',
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  TARJETA DE PUBLICACION EN LISTA
// =============================================================================
class _TarjetaPublicacion extends StatelessWidget {
  final Publicacion publicacion;
  final bool esUltima;

  const _TarjetaPublicacion({required this.publicacion, this.esUltima = false});

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return DateFormat('MMMM yyyy', 'es').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = _formatearFecha(publicacion.fechaEvento);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 24, esUltima ? 8 : 0),
      child: Stack(
        children: [
          if (!esUltima)
            Positioned(
              top: 12,
              bottom: 0,
              left: 10,
              width: 2,
              child: ColoredBox(color: Colors.grey.shade300),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline: dot + linea vertical (altura completa)
              SizedBox(
                width: 22,
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD32F2F),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Fecha + tarjeta
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fechaTexto.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          fechaTexto.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaDetallePublicacion(
                              publicacion: publicacion,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (publicacion.urlsImagenes.isNotEmpty)
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: ImagenUniversal(
                                  url: publicacion.urlsImagenes.first,
                                  fit: BoxFit.cover,
                                  anchoCache: 600,
                                  reemplazoVisual: _CoverPlaceholder(
                                    initial: publicacion.titulo[0],
                                  ),
                                ),
                              )
                            else
                              _CoverPlaceholder(
                                initial: publicacion.titulo[0],
                                height: 180,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (publicacion.nombreEvento.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1A1A1A,
                                        ).withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        publicacion.nombreEvento,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF555555),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    publicacion.titulo,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1A1A1A),
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    publicacion.descripcion.replaceAll(
                                      '\n',
                                      ' ',
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Wrap(
                                      alignment:
                                          publicacion.urlsImagenes.length > 1
                                          ? WrapAlignment.spaceBetween
                                          : WrapAlignment.end,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        if (publicacion.urlsImagenes.length > 1)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.photo_library_outlined,
                                                size: 14,
                                                color: Color(0xFF888888),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${publicacion.urlsImagenes.length} fotos',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Leer más',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFFD32F2F),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward,
                                              size: 14,
                                              color: Color(0xFFD32F2F),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  PLACEHOLDER DE PORTADA
// =============================================================================
class _CoverPlaceholder extends StatelessWidget {
  final String initial;
  final double? height;

  const _CoverPlaceholder({required this.initial, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.playfairDisplay(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
