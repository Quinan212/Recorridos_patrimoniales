import 'package:audio_session/audio_session.dart';

/// Solo configura la sesión de audio del sistema operativo una vez al inicio.
/// AudioProvider es el único que crea y maneja el AudioPlayer.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }
}
