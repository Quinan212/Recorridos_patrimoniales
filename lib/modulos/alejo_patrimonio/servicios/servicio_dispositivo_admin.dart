import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_identidad_dispositivo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/configuracion_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstadoDispositivoAdmin {
  const EstadoDispositivoAdmin({
    required this.identidad,
    required this.esAdmin,
    required this.mensaje,
    this.etiquetaAdmin,
  });

  final IdentidadDispositivo identidad;
  final bool esAdmin;
  final String mensaje;
  final String? etiquetaAdmin;
}

class ServicioDispositivoAdmin {
  const ServicioDispositivoAdmin();

  Future<EstadoDispositivoAdmin> verificarDispositivoActual() async {
    final identidad = await const ServicioIdentidadDispositivo()
        .obtenerIdentidad();
    if (!ConfiguracionSupabase.estaConfigurado) {
      return EstadoDispositivoAdmin(
        identidad: identidad,
        esAdmin: false,
        mensaje: 'Supabase no esta configurado en esta ejecucion.',
      );
    }

    final cliente = Supabase.instance.client;
    await _registrarDispositivoVisto(cliente, identidad);

    try {
      final fila = await cliente
          .from('admin_devices')
          .select('device_id, enabled, label')
          .eq('device_id', identidad.id)
          .maybeSingle();

      if (fila == null) {
        return EstadoDispositivoAdmin(
          identidad: identidad,
          esAdmin: false,
          mensaje:
              'Este dispositivo todavia no esta habilitado como admin en Supabase.',
        );
      }

      final habilitado = fila['enabled'] == true;
      final etiqueta = (fila['label'] as String?)?.trim();
      return EstadoDispositivoAdmin(
        identidad: identidad,
        esAdmin: habilitado,
        etiquetaAdmin: etiqueta,
        mensaje: habilitado
            ? 'Este dispositivo tiene acceso admin habilitado.'
            : 'Este dispositivo figura en admin_devices, pero esta deshabilitado.',
      );
    } on PostgrestException catch (error) {
      return EstadoDispositivoAdmin(
        identidad: identidad,
        esAdmin: false,
        mensaje: 'No se pudo leer admin_devices: ${error.message}',
      );
    } catch (error) {
      return EstadoDispositivoAdmin(
        identidad: identidad,
        esAdmin: false,
        mensaje: 'Fallo la comprobacion admin: $error',
      );
    }
  }

  Future<void> _registrarDispositivoVisto(
    SupabaseClient cliente,
    IdentidadDispositivo identidad,
  ) async {
    try {
      await cliente.from('device_registry').upsert({
        'device_id': identidad.id,
        'label': identidad.label,
        'last_active_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Device registry is convenience-only; admin checks can still work.
    }
  }
}
