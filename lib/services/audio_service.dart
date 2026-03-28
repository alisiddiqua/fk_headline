import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  String? _currentTitle;
  
  AudioPlayer get player => _player;
  String? get currentTitle => _currentTitle;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> play(String url, {String? title, String? artist}) async {
    _currentTitle = title;
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            album: "Islamiafkaar",
            title: title ?? "Unknown Title",
            artist: artist ?? "Fikrokhabar",
          ),
        ),
      );
      _player.play();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void stop() => _player.stop();
  void pause() => _player.pause();
  void resume() => _player.play();

  void dispose() {
    _player.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

class MediaItem {
  final String id;
  final String album;
  final String title;
  final String artist;

  MediaItem({required this.id, required this.album, required this.title, required this.artist});
}
