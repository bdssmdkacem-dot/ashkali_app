import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Singleton audio service, same pattern as وقتي / أرقامي / حروفي.
/// Handles both Arabic TTS (shape names) and short sound effects
/// (tap / success / error / chapter complete).
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.42); // slower for kids
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    _initialized = true;
  }

  /// Speak an Arabic word/phrase (e.g. shape name "دائرة").
  Future<void> speak(String arabicText) async {
    await _tts.stop();
    await _tts.speak(arabicText);
  }

  Future<void> stopSpeaking() => _tts.stop();

  Future<void> playTap() => _playSfx('tap.wav');
  Future<void> playSuccess() => _playSfx('success.wav');
  Future<void> playError() => _playSfx('error.wav');
  Future<void> playComplete() => _playSfx('complete.wav');

  Future<void> _playSfx(String assetFile) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/$assetFile'));
    } catch (_) {
      // Fail silently if audio device unavailable - never block gameplay.
    }
  }

  void dispose() {
    _tts.stop();
    _sfxPlayer.dispose();
  }
}
