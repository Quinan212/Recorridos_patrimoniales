import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentidadDispositivo {
  const IdentidadDispositivo({required this.id, required this.label});

  final String id;
  final String label;
}

class ServicioIdentidadDispositivo {
  const ServicioIdentidadDispositivo();

  static const _clavePreferencias = 'device_identity.v1';
  static const _canal = MethodChannel(
    'ar.maillet.recorridos_patrimoniales/device_identity',
  );

  Future<IdentidadDispositivo> obtenerIdentidad() async {
    final id = await obtenerOCrearIdDispositivo();
    final label = await obtenerEtiquetaDispositivoActual();
    return IdentidadDispositivo(id: id, label: label);
  }

  Future<String> obtenerOCrearIdDispositivo() async {
    final prefs = await SharedPreferences.getInstance();

    if (Platform.isAndroid) {
      final platformId = await _leerIdDispositivoAndroid();
      if (platformId != null) {
        await prefs.setString(_clavePreferencias, platformId);
        return platformId;
      }
    }

    final existente = prefs.getString(_clavePreferencias)?.trim();
    if (existente != null && existente.isNotEmpty) {
      return existente;
    }

    final creado = _generarIdDispositivo();
    await prefs.setString(_clavePreferencias, creado);
    return creado;
  }

  Future<String> obtenerEtiquetaDispositivoActual() async {
    if (Platform.isAndroid) {
      final label = await _leerEtiquetaDispositivoAndroid();
      if (label != null) return label;
      return 'Dispositivo Android';
    }

    final sistema = Platform.operatingSystem;
    return sistema.isEmpty ? 'Dispositivo' : _capitalizarTitulo(sistema);
  }

  String _generarIdDispositivo() {
    final millis = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return 'dev_$millis';
  }

  Future<String?> _leerIdDispositivoAndroid() async {
    try {
      final resultado = await _canal.invokeMethod<String>('getAndroidDeviceId');
      final limpio = resultado?.trim();
      if (limpio == null || limpio.isEmpty) {
        return null;
      }
      if (limpio.startsWith('emu_') || limpio.startsWith('and_')) {
        return limpio;
      }
      return 'and_$limpio';
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<String?> _leerEtiquetaDispositivoAndroid() async {
    try {
      final resultado = await _canal.invokeMethod<String>(
        'getAndroidDeviceLabel',
      );
      final limpio = resultado?.trim();
      if (limpio == null || limpio.isEmpty) {
        return null;
      }
      return limpio;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  String _capitalizarTitulo(String valor) {
    if (valor.isEmpty) return valor;
    return valor[0].toUpperCase() + valor.substring(1).toLowerCase();
  }
}
