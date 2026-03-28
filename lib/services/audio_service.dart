import 'dart:async';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/islamiafkaar_provider.dart';

enum PlaybackMode { normal, loop, shuffle }

// ─── Background Audio Handler ────────────────────────────────────────────────
class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    // Broadcast state changes
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    
    // Handle track completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async {
    // Logic for next track will be handled by the service/notifier
  }

  @override
  Future<void> skipToPrevious() async {
    // Logic for previous track will be handled by the service/notifier
  }

  Future<void> setSource(String url, MediaItem item) async {
    mediaItem.add(item);
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    } catch (e) {
      print("Error setting audio source: $e");
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

// ─── Audio Service Wrapper for Riverpod ─────────────────────────────────────
class AudioServiceWrapper {
  late MyAudioHandler _handler;
  List<PodcastItem> _playlist = [];
  int _currentIndex = -1;
  PlaybackMode _mode = PlaybackMode.normal;

  MyAudioHandler get handler => _handler;
  AudioPlayer get player => _handler._player;
  
  String? get currentTitle => _handler.mediaItem.value?.title;
  String? get currentSpeaker => _handler.mediaItem.value?.artist;

  Future<void> init() async {
    _handler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.fikrokhabar.fkheadline.channel.audio',
        androidNotificationChannelName: 'Islamiafkaar Playback',
        androidNotificationOngoing: true,
      ),
    );
  }

  Future<void> playFromPlaylist(List<PodcastItem> playlist, int index) async {
    _playlist = playlist;
    _currentIndex = index;
    await _playIndex(index);
  }

  Future<void> _playIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    final item = _playlist[index];

    final mediaItem = MediaItem(
      id: item.audioUrl,
      album: "Islamiafkaar",
      title: item.title,
      artist: item.speakerName,
      artUri: Uri.parse("https://i.ibb.co/LhyMxh8/Islami-Afkaar-Logo.png"), // Provided logo hosted online for notification artwork
      duration: _parseDuration(item.duration),
    );

    await _handler.setSource(item.audioUrl, mediaItem);
    _handler.play();
  }

  void playNext() {
    if (_playlist.isEmpty) return;
    if (_mode == PlaybackMode.loop) {
      _playIndex(_currentIndex);
    } else if (_mode == PlaybackMode.shuffle) {
      final rand = Random();
      _playIndex(rand.nextInt(_playlist.length));
    } else {
      if (_currentIndex < _playlist.length - 1) {
        _playIndex(_currentIndex + 1);
      }
    }
  }

  void playPrevious() {
    if (_playlist.isEmpty || _currentIndex <= 0) return;
    _playIndex(_currentIndex - 1);
  }

  void seekForward() => _handler.seek(player.position + const Duration(seconds: 10));
  void seekBackward() => _handler.seek(player.position - const Duration(seconds: 10));

  void setMode(PlaybackMode mode) => _mode = mode;
  void stop() => _handler.stop();
  void pause() => _handler.pause();
  void resume() => _handler.play();

  Duration? _parseDuration(String d) {
    if (d.isEmpty) return null;
    final parts = d.split(':').map(int.parse).toList();
    if (parts.length == 2) return Duration(minutes: parts[0], seconds: parts[1]);
    if (parts.length == 3) return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    return null;
  }
}

final audioServiceProvider = Provider<AudioServiceWrapper>((ref) {
  final service = AudioServiceWrapper();
  // Note: initialization must happen in main() for audio_service to work correctly
  return service;
});
