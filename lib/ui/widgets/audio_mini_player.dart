import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/audio_service.dart';

class AudioMiniPlayer extends ConsumerWidget {
  const AudioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);

    return StreamBuilder<PlayerState>(
      stream: audioService.player.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null || state.processingState == ProcessingState.idle) {
          return const SizedBox.shrink();
        }
        final playing = state.playing;

        return GestureDetector(
          onTap: () {
            // Open full player screen on tap
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AudioPlayerScreen()),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.mic, color: Colors.indigo, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audioService.currentTitle ?? 'Now Playing',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (audioService.currentSpeaker != null &&
                          audioService.currentSpeaker!.isNotEmpty)
                        Text(
                          audioService.currentSpeaker!,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.indigo,
                  ),
                  onPressed: () {
                    if (playing) {
                      audioService.pause();
                    } else {
                      audioService.resume();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () => audioService.stop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// Full Screen Audio Player
// ─────────────────────────────────────────
class AudioPlayerScreen extends ConsumerStatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen> {
  PlaybackMode _mode = PlaybackMode.normal;

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider);
    final player = audioService.player;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamiafkaar'),
        centerTitle: true,
      ),
      body: StreamBuilder<PlayerState>(
        stream: player.playerStateStream,
        builder: (context, stateSnap) {
          final playing = stateSnap.data?.playing ?? false;

          return Column(
            children: [
              const SizedBox(height: 30),

              // Album art / icon
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.indigo, size: 90),
              ),
              const SizedBox(height: 30),

              // Title & Speaker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      audioService.currentTitle ?? '—',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      audioService.currentSpeaker ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Progress bar + timestamps
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, posSnap) {
                  final position = posSnap.data ?? Duration.zero;
                  final duration = player.duration ?? Duration.zero;
                  final progress = duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (val) {
                            final seek = Duration(
                              milliseconds: (val * duration.inMilliseconds).round(),
                            );
                            player.seek(seek);
                          },
                          activeColor: Colors.indigo,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position),
                                  style: const TextStyle(fontSize: 12)),
                              Text(_formatDuration(duration),
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Seek -10s | Play/Pause | Seek +10s
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 42,
                    icon: const Icon(Icons.replay_10),
                    onPressed: audioService.seekBackward,
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => playing ? audioService.pause() : audioService.resume(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 42,
                    icon: const Icon(Icons.forward_10),
                    onPressed: audioService.seekForward,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Previous | Loop/Shuffle/Normal | Next
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 34,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      audioService.playPrevious();
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 8),
                  // Mode toggle: Normal → Loop → Shuffle → Normal
                  IconButton(
                    iconSize: 28,
                    color: _mode != PlaybackMode.normal ? Colors.indigo : Colors.grey,
                    icon: Icon(
                      _mode == PlaybackMode.loop
                          ? Icons.repeat_one
                          : _mode == PlaybackMode.shuffle
                              ? Icons.shuffle
                              : Icons.repeat,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_mode == PlaybackMode.normal) {
                          _mode = PlaybackMode.loop;
                        } else if (_mode == PlaybackMode.loop) {
                          _mode = PlaybackMode.shuffle;
                        } else {
                          _mode = PlaybackMode.normal;
                        }
                        audioService.setMode(_mode);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    iconSize: 34,
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      audioService.playNext();
                      setState(() {});
                    },
                  ),
                ],
              ),

              // Mode label
              Text(
                _mode == PlaybackMode.loop
                    ? 'Loop'
                    : _mode == PlaybackMode.shuffle
                        ? 'Shuffle'
                        : 'Normal',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          );
        },
      ),
    );
  }
}
