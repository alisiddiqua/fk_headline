import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/islamiafkaar_provider.dart';

enum PlaybackMode { normal, loop, shuffle }

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  List<PodcastItem> _playlist = [];
  int _currentIndex = -1;
  PlaybackMode _mode = PlaybackMode.normal;
  String? _currentTitle;
  String? _currentSpeaker;

  AudioPlayer get player => _player;
  String? get currentTitle => _currentTitle;
  String? get currentSpeaker => _currentSpeaker;
  int get currentIndex => _currentIndex;
  List<PodcastItem> get playlist => _playlist;
  PlaybackMode get playbackMode => _mode;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    // Auto-play next when current track completes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Future<void> playFromPlaylist(List<PodcastItem> playlist, int index) async {
    _playlist = playlist;
    _currentIndex = index;
    await _playItem(playlist[index]);
  }

  Future<void> _playItem(PodcastItem item) async {
    _currentTitle = item.title;
    _currentSpeaker = item.speakerName;
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(item.audioUrl)),
      );
      _player.play();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void playNext() {
    if (_playlist.isEmpty) return;
    if (_mode == PlaybackMode.loop) {
      _playItem(_playlist[_currentIndex]);
    } else if (_mode == PlaybackMode.shuffle) {
      final rand = Random();
      _currentIndex = rand.nextInt(_playlist.length);
      _playItem(_playlist[_currentIndex]);
    } else {
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
        _playItem(_playlist[_currentIndex]);
      }
    }
  }

  void playPrevious() {
    if (_playlist.isEmpty || _currentIndex <= 0) return;
    _currentIndex--;
    _playItem(_playlist[_currentIndex]);
  }

  void seekForward() {
    final pos = _player.position + const Duration(seconds: 10);
    _player.seek(pos);
  }

  void seekBackward() {
    final pos = _player.position - const Duration(seconds: 10);
    _player.seek(pos < Duration.zero ? Duration.zero : pos);
  }

  void setMode(PlaybackMode mode) => _mode = mode;

  void stop() => _player.stop();
  void pause() => _player.pause();
  void resume() => _player.play();

  void dispose() => _player.dispose();
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});
