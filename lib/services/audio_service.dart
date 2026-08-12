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
  bool _ttsAvailable = true;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('ar-SA');
      await _tts.setSpeechRate(0.42); // slower for kids
      await _tts.setPitch(1.05);
      await _tts.setVolume(1.0);
    } catch (_) {
      // Some devices/emulators have no TTS engine installed at all. This
      // runs in main() before runApp() - an unguarded failure here would
      // crash the app on startup, the same way the missing AdMob
      // APPLICATION_ID meta-data did. Shape names just won't be spoken.
      _ttsAvailable = false;
    }
    try {
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (_) {
      // Non-fatal - playback will just fall back to default release mode.
    }
    _initialized = true;
  }

  /// Speak an Arabic word/phrase (e.g. shape name "دائرة").
  Future<void> speak(String arabicText) async {
    if (!_ttsAvailable) return;
    try {
      await _tts.stop();
      await _tts.speak(arabicText);
    } catch (_) {
      // Never let a TTS hiccup interrupt gameplay.
    }
  }

  Future<void> stopSpeaking() => _tts.stop();

  Future<void> playTap() => _playSfx('tap.wav');
  Future<void> playSuccess() => _playSfx('success.wav');
  Future<void> playError() => _playSfx('error.wav');
  Future<void> playComplete() => _playSfx('complete.wav');
  Future<void> playUnlock() => _playSfx('unlock.wav');
  Future<void> playStar() => _playSfx('star.wav');

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
