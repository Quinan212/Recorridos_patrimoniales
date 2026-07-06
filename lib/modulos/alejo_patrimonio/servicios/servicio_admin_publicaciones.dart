import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_dispositivo_admin.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_identidad_dispositivo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicioAdminPublicaciones {
  const ServicioAdminPublicaciones();

  static const _nombreBucket = 'publication-images';
  static const _anchoMaximoSubida = 1800.0;
  static const _calidadImagen = 82;

  // ---------------------------------------------------------------------------
  //  CREAR PUBLICACION
  // ---------------------------------------------------------------------------
  Future<String> crearPublicacion({
    required String titulo,
    required String descripcion,
    required String nombreEvento,
    DateTime? fechaEvento,
  }) async {
    final estadoAdmin = await const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
    if (!estadoAdmin.esAdmin) {
      throw StateError('Este dispositivo no tiene permiso admin.');
    }

    final cliente = Supabase.instance.client;
    final resultado = await cliente.from('publications').insert({
      'title': titulo,
      'description': descripcion,
      'event_name': nombreEvento,
      'event_date': fechaEvento?.toIso8601String(),
      'created_by_device_id': estadoAdmin.identidad.id,
      'is_published': true,
    }).select('id').single();

    return resultado['id'] as String;
  }

  // ---------------------------------------------------------------------------
  //  ACTUALIZAR PUBLICACION
  // ---------------------------------------------------------------------------
  Future<void> actualizarPublicacion({
    required String id,
    required String titulo,
    required String descripcion,
    required String nombreEvento,
    DateTime? fechaEvento,
  }) async {
    final estadoAdmin = await const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
    if (!estadoAdmin.esAdmin) {
      throw StateError('Este dispositivo no tiene permiso admin.');
    }

    await Supabase.instance.client.from('publications').update({
      'title': titulo,
      'description': descripcion,
      'event_name': nombreEvento,
      'event_date': fechaEvento?.toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  //  ELIMINAR PUBLICACION
  // ---------------------------------------------------------------------------
  Future<void> eliminarPublicacion(String id) async {
    final estadoAdmin = await const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
    if (!estadoAdmin.esAdmin) {
      throw StateError('Este dispositivo no tiene permiso admin.');
    }

    final cliente = Supabase.instance.client;

    // Primero obtener y borrar todas las imagenes del storage
    final imagenes = await cliente
        .from('publication_images')
        .select('storage_path')
        .eq('publication_id', id);

    final rutasStorage = imagenes
        .map<String?>((row) => row['storage_path'] as String?)
        .where((r) => r != null && r.isNotEmpty)
        .cast<String>()
        .toList();

    if (rutasStorage.isNotEmpty) {
      await cliente.storage.from(_nombreBucket).remove(rutasStorage);
    }

    // El delete en cascada borra las filas de publication_images
    await cliente.from('publications').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  //  SUBIR IMAGEN A PUBLICACION
  // ---------------------------------------------------------------------------
  Future<String> subirImagen({
    required String publicationId,
    required int orden,
    String? caption,
  }) async {
    final estadoAdmin = await const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
    if (!estadoAdmin.esAdmin) {
      throw StateError('Este dispositivo no tiene permiso admin.');
    }

    final imagen = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _anchoMaximoSubida,
      imageQuality: _calidadImagen,
    );
    if (imagen == null) {
      throw CargaFotoPublicacionCancelada();
    }

    final bytes = await imagen.readAsBytes();
    final extension = _obtenerExtensionArchivo(imagen.name);
    final idDispositivo = estadoAdmin.identidad.id;
    final ruta =
        'publication_uploads/$idDispositivo/$publicationId/${DateTime.now().millisecondsSinceEpoch}_${_hexAleatorio(5)}.$extension';
    final cliente = Supabase.instance.client;

    await cliente.storage.from(_nombreBucket).uploadBinary(
      ruta,
      Uint8List.fromList(bytes),
      fileOptions: FileOptions(
        contentType: _tipoContenidoPara(extension),
        cacheControl: '31536000',
      ),
    );

    try {
      await cliente.from('publication_images').insert({
        'publication_id': publicationId,
        'storage_path': ruta,
        'caption': caption ?? '',
        'sort_order': orden,
      });
    } catch (error) {
      // Si falla el registro, limpiar el archivo subido
      try {
        await cliente.storage.from(_nombreBucket).remove([ruta]);
      } catch (e) {
        debugPrint('No se pudo limpiar la imagen subida: $e');
      }
      rethrow;
    }

    return cliente.storage.from(_nombreBucket).getPublicUrl(ruta);
  }

  // ---------------------------------------------------------------------------
  //  BORRAR IMAGEN DE PUBLICACION
  // ---------------------------------------------------------------------------
  Future<void> borrarImagen({
    required String publicationId,
    required String storagePath,
  }) async {
    final estadoAdmin = await const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
    if (!estadoAdmin.esAdmin) {
      throw StateError('Este dispositivo no tiene permiso admin.');
    }

    final cliente = Supabase.instance.client;
    await cliente.storage.from(_nombreBucket).remove([storagePath]);
    await cliente
        .from('publication_images')
        .delete()
        .eq('publication_id', publicationId)
        .eq('storage_path', storagePath);
  }

  // ---------------------------------------------------------------------------
  //  HELPERS
  // ---------------------------------------------------------------------------
  String _obtenerExtensionArchivo(String nombreArchivo) {
    final punto = nombreArchivo.lastIndexOf('.');
    if (punto == -1 || punto == nombreArchivo.length - 1) return 'jpg';
    final extension = nombreArchivo.substring(punto + 1).toLowerCase();
    return switch (extension) {
      'png' || 'webp' || 'jpg' || 'jpeg' => extension,
      _ => 'jpg',
    };
  }

  String _tipoContenidoPara(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  String _hexAleatorio(int largo) {
    final aleatorio = Random.secure();
    return List.generate(
      largo,
      (_) => aleatorio.nextInt(16).toRadixString(16),
    ).join();
  }
}

class CargaFotoPublicacionCancelada implements Exception {
  const CargaFotoPublicacionCancelada();
}

/// Helper para subir imagenes directamente desde el formulario
/// (sin pasar por el ImagePicker del servicio).
class SupabaseServiceHelper {
  static const _nombreBucket = 'publication-images';

  static Future<void> subirImagenDirecta({
    required String publicationId,
    required List<int> bytes,
    required int orden,
    required String contentType,
  }) async {
    final extension = contentType.split('/').last;
    final cliente = Supabase.instance.client;
    final idDispositivo =
        await const ServicioIdentidadDispositivo().obtenerOCrearIdDispositivo();
    final hex = List.generate(
      5,
      (_) => DateTime.now().microsecondsSinceEpoch.toRadixString(16),
    ).join();
    final ruta =
        'publication_uploads/$idDispositivo/$publicationId/${DateTime.now().millisecondsSinceEpoch}_$hex.$extension';

    await cliente.storage.from(_nombreBucket).uploadBinary(
      ruta,
      Uint8List.fromList(bytes),
      fileOptions: FileOptions(
        contentType: contentType,
        cacheControl: '31536000',
      ),
    );

    await cliente.from('publication_images').insert({
      'publication_id': publicationId,
      'storage_path': ruta,
      'caption': '',
      'sort_order': orden,
    });
  }
}
