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
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (processingState == ProcessingState.idle || processingState == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.music_note, color: Colors.indigo),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<Duration?>(
                  stream: audioService.player.positionStream,
                  builder: (context, posSnap) {
                    // Title handling will be improved subsequently with global state
                    return Text(
                      audioService.currentTitle ?? "Now Playing",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  playing == true ? Icons.pause : Icons.play_arrow,
                  color: Colors.indigo,
                ),
                onPressed: () {
                  if (playing == true) {
                    audioService.pause();
                  } else {
                    audioService.resume();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                onPressed: () {
                  audioService.stop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
