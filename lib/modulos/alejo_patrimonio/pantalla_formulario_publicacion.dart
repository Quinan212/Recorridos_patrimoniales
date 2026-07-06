import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_admin_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_dispositivo_admin.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_publicaciones.dart';

/// Formulario para que admins creen nuevas publicaciones con fotos.
class PantallaFormularioPublicacion extends StatefulWidget {
  const PantallaFormularioPublicacion({super.key});

  @override
  State<PantallaFormularioPublicacion> createState() =>
      _PantallaFormularioPublicacionState();
}

class _PantallaFormularioPublicacionState
    extends State<PantallaFormularioPublicacion> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _eventoController = TextEditingController();
  DateTime? _fechaEvento;
  bool _guardando = false;
  bool _verificandoAdmin = true;
  bool _esAdmin = false;

  // Imagenes seleccionadas (paths locales) antes de subir
  final List<XFile> _imagenesSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  Future<void> _verificarAdmin() async {
    final estado =
        await const ServicioDispositivoAdmin().verificarDispositivoActual();
    if (!mounted) return;
    setState(() {
      _esAdmin = estado.esAdmin;
      _verificandoAdmin = false;
    });

    if (!estado.esAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo admins pueden crear publicaciones.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _eventoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_verificandoAdmin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_esAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso denegado'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Solo admins pueden crear publicaciones',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F3),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Nueva Publicacion',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _guardarPublicacion,
            child: _guardando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Publicar',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD32F2F),
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Titulo --
              _Label(texto: 'TITULO DE LA PUBLICACION'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tituloController,
                style: GoogleFonts.inter(fontSize: 16),
                decoration: _inputDecoration('Ej: Feria del Libro 2025'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // -- Nombre del evento --
              _Label(texto: 'NOMBRE DEL EVENTO / INSTITUCION'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _eventoController,
                style: GoogleFonts.inter(fontSize: 16),
                decoration: _inputDecoration(
                  'Ej: Fundacion Cultural de Concordia',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),

              // -- Fecha --
              _Label(texto: 'FECHA DEL EVENTO'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _seleccionarFecha,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _fechaEvento != null
                            ? '${_fechaEvento!.day}/${_fechaEvento!.month}/${_fechaEvento!.year}'
                            : 'Seleccionar fecha',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: _fechaEvento != null
                              ? const Color(0xFF1A1A1A)
                              : Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      if (_fechaEvento != null)
                        GestureDetector(
                          onTap: () => setState(() => _fechaEvento = null),
                          child: const Icon(
                            Icons.clear,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // -- Descripcion --
              _Label(texto: 'DESCRIPCION / RESEÑA'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                style: GoogleFonts.inter(fontSize: 15, height: 1.5),
                decoration: _inputDecoration(
                  'Contanos como fue la presentacion, que se compartio, '
                  'la recepcion del publico...',
                ).copyWith(
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 8,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),

              // -- Fotos --
              _Label(texto: 'FOTOS DEL EVENTO'),
              const SizedBox(height: 8),
              _armarSelectorFotos(),
              const SizedBox(height: 32),

              // -- Disclaimer --
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFCC80).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Color(0xFFE65100),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'La publicacion se creara y sera visible para todos '
                        'los usuarios. Las fotos se subiran a Supabase Storage '
                        'y se asociaran automaticamente.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.4,
                          color: const Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  //  SELECTOR DE FOTOS
  // -------------------------------------------------------------------------
  Widget _armarSelectorFotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imagenesSeleccionadas.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imagenesSeleccionadas.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == _imagenesSeleccionadas.length) {
                  return _BotonAgregarFoto(onTap: _agregarFoto);
                }
                return _MiniaturaFoto(
                  xfile: _imagenesSeleccionadas[index],
                  onRemove: () => setState(
                    () => _imagenesSeleccionadas.removeAt(index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_imagenesSeleccionadas.isEmpty)
          _BotonAgregarFotoGrande(onTap: _agregarFoto),
      ],
    );
  }

  Future<void> _agregarFoto() async {
    final imagen = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 82,
    );
    if (imagen != null) {
      setState(() => _imagenesSeleccionadas.add(imagen));
    }
  }

  // -------------------------------------------------------------------------
  //  FECHA PICKER
  // -------------------------------------------------------------------------
  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaEvento ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', ''),
    );
    if (fecha != null) {
      setState(() => _fechaEvento = fecha);
    }
  }

  // -------------------------------------------------------------------------
  //  GUARDAR PUBLICACION
  // -------------------------------------------------------------------------
  Future<void> _guardarPublicacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      // 1. Crear la publicacion en Supabase
      final idPublicacion = await const ServicioAdminPublicaciones()
          .crearPublicacion(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        nombreEvento: _eventoController.text.trim(),
        fechaEvento: _fechaEvento,
      );

      // 2. Subir imagenes seleccionadas
      if (_imagenesSeleccionadas.isNotEmpty) {
        for (var i = 0; i < _imagenesSeleccionadas.length; i++) {
          final xfile = _imagenesSeleccionadas[i];
          final bytes = await xfile.readAsBytes();
          final extension = xfile.name.split('.').last.toLowerCase();
          final contentType = switch (extension) {
            'png' => 'image/png',
            'webp' => 'image/webp',
            _ => 'image/jpeg',
          };

          await SupabaseServiceHelper.subirImagenDirecta(
            publicationId: idPublicacion,
            bytes: bytes,
            orden: i,
            contentType: contentType,
          );
        }
      }

      // 3. Recargar publicaciones
      if (!mounted) return;
      await context.read<RepositorioPublicaciones>().cargar();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicacion creada correctamente')),
      );
      Navigator.pop(context);
    } on CargaFotoPublicacionCancelada {
      // No hacer nada
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear publicacion: $error')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // -------------------------------------------------------------------------
  //  HELPERS
  // -------------------------------------------------------------------------
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// =============================================================================
//  LABEL
// =============================================================================
class _Label extends StatelessWidget {
  final String texto;

  const _Label({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.5,
        color: Colors.grey[500],
      ),
    );
  }
}

// =============================================================================
//  MINIATURA DE FOTO SELECCIONADA
// =============================================================================
class _MiniaturaFoto extends StatelessWidget {
  final XFile xfile;
  final VoidCallback onRemove;

  const _MiniaturaFoto({required this.xfile, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.file(
                File(xfile.path),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  BOTON AGREGAR FOTO (horizontal)
// =============================================================================
class _BotonAgregarFoto extends StatelessWidget {
  final VoidCallback onTap;

  const _BotonAgregarFoto({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text(
              'Agregar',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  BOTON AGREGAR FOTO (grande, cuando no hay ninguna)
// =============================================================================
class _BotonAgregarFotoGrande extends StatelessWidget {
  final VoidCallback onTap;

  const _BotonAgregarFotoGrande({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Agregar fotos del evento',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
