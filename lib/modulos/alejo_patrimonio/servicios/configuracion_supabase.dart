import 'dart:io' show Platform;

class ConfiguracionSupabase {
  /// Reads SUPABASE_URL from:
  /// 1. --dart-define (compile-time constant, los usa en release)
  /// 2. Platform.environment (variables del sistema)
  /// 3. Fallback hardcodeado para DEBUG únicamente
  static String get url {
    // Intentar 1: dart-define (producción)
    const desdeDartDefine = String.fromEnvironment('SUPABASE_URL');
    if (desdeDartDefine.isNotEmpty) return desdeDartDefine;

    // Intentar 2: variable de entorno del sistema
    final desdeEntorno = Platform.environment['SUPABASE_URL'];
    if (desdeEntorno != null && desdeEntorno.isNotEmpty) return desdeEntorno;

    return '';
  }

  /// Reads SUPABASE_ANON_KEY from:
  /// 1. --dart-define (compile-time constant)
  /// 2. Platform.environment (variables del sistema)
  static String get anonKey {
    // Intentar 1: dart-define (producción)
    const desdeDartDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (desdeDartDefine.isNotEmpty) return desdeDartDefine;

    // Intentar 2: variable de entorno del sistema
    final desdeEntorno = Platform.environment['SUPABASE_ANON_KEY'];
    if (desdeEntorno != null && desdeEntorno.isNotEmpty) return desdeEntorno;

    return '';
  }

  static bool get estaConfigurado => url.isNotEmpty && anonKey.isNotEmpty;
}
