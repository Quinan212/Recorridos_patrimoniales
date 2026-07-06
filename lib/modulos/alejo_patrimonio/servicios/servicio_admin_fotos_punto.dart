import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_dispositivo_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicioAdminFotosPunto {
  const ServicioAdminFotosPunto();

  static const _nombreBucket = 'point-images';
  static const _anchoMaximoSubida = 1800.0;
  static const _calidadImagen = 82;

  Future<XFile?> elegirImagen() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _anchoMaximoSubida,
      imageQuality: _calidadImagen,
    );
  }

  Future<String> subirFotoPunto({
    required PuntoPatrimonial punto,
    required int orden,
  }) async {
    final estadoAdmin = await const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
    if (!estadoAdmin.esAdmin) {
      throw StateError('Este dispositivo no tiene permiso admin.');
    }

    final imagen = await elegirImagen();
    if (imagen == null) {
      throw CargaFotoCancelada();
    }

    final bytes = await imagen.readAsBytes();
    final extension = _obtenerExtensionArchivo(imagen.name);
    final idDispositivo = estadoAdmin.identidad.id;
    final ruta =
        'admin_uploads/$idDispositivo/${punto.id}/${DateTime.now().millisecondsSinceEpoch}_${_hexAleatorio(5)}.$extension';
    final cliente = Supabase.instance.client;

    await cliente.storage
        .from(_nombreBucket)
        .uploadBinary(
          ruta,
          bytes,
          fileOptions: FileOptions(
            contentType: _tipoContenidoPara(extension),
            cacheControl: '31536000',
          ),
        );

    try {
      await cliente.from('point_images').insert({
        'point_id': punto.id,
        'storage_path': ruta,
        'sort_order': orden,
        'uploaded_by_device_id': idDispositivo,
      });
    } catch (error) {
      try {
        await cliente.storage.from(_nombreBucket).remove([ruta]);
      } catch (errorLimpieza, stackTraceLimpieza) {
        debugPrint('No se pudo limpiar la foto subida: $errorLimpieza');
        debugPrintStack(stackTrace: stackTraceLimpieza);
      }
      rethrow;
    }

    return cliente.storage.from(_nombreBucket).getPublicUrl(ruta);
  }

  Future<void> borrarFotoPunto({
    required PuntoPatrimonial punto,
    required String urlImagen,
  }) async {
    final estadoAdmin = await const ServicioDispositivoAdmin()
        .verificarDispositivoActual();
    if (!estadoAdmin.esAdmin) {
      throw StateError('Este dispositivo no tiene permiso admin.');
    }

    final rutaStorage = _rutaStorageDesdeUrl(urlImagen);
    if (rutaStorage == null || rutaStorage.isEmpty) {
      throw StateError('No se pudo identificar la foto remota.');
    }

    final cliente = Supabase.instance.client;
    await cliente.storage.from(_nombreBucket).remove([rutaStorage]);

    await cliente
        .from('point_images')
        .delete()
        .eq('point_id', punto.id)
        .eq('storage_path', rutaStorage);
  }

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

  String? _rutaStorageDesdeUrl(String urlImagen) {
    final marcador = '/storage/v1/object/public/$_nombreBucket/';
    final indiceMarcador = urlImagen.indexOf(marcador);
    if (indiceMarcador == -1) return null;

    final rutaCruda = urlImagen.substring(indiceMarcador + marcador.length);
    return Uri.decodeFull(rutaCruda.split('?').first);
  }

  String _hexAleatorio(int largo) {
    final aleatorio = Random.secure();
    return List.generate(
      largo,
      (_) => aleatorio.nextInt(16).toRadixString(16),
    ).join();
  }
}

class CargaFotoCancelada implements Exception {
  const CargaFotoCancelada();
}
