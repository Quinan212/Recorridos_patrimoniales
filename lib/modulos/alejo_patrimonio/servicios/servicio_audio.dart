import 'package:audio_session/audio_session.dart';

/// Solo configura la sesión de audio del sistema operativo una vez al inicio.
/// ControladorAudio es el único que crea y maneja el AudioPlayer.
class ServicioAudio {
  static final ServicioAudio _instance = ServicioAudio._internal();
  factory ServicioAudio() => _instance;
  ServicioAudio._internal();

  Future<void> inicializar() async {
    final sesion = await AudioSession.instance;
    await sesion.configure(const AudioSessionConfiguration.music());
  }
}
