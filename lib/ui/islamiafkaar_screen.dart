import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/islamiafkaar_provider.dart';
import '../services/audio_service.dart';
import 'widgets/audio_mini_player.dart';

class IslamiafkaarScreen extends ConsumerWidget {
  const IslamiafkaarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastAsync = ref.watch(islamiafkaarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamiafkaar'),
      ),
      body: podcastAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No audio found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 140),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.indigo.withOpacity(0.1),
                            child: const Icon(Icons.mic, color: Colors.indigo),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.indigo.withOpacity(0.1),
                            child: const Icon(Icons.mic, color: Colors.indigo),
                          ),
                        )
                      : Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.mic, color: Colors.indigo),
                        ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.speakerName.isNotEmpty)
                      Text(
                        item.speakerName,
                        style: const TextStyle(fontSize: 12, color: Colors.indigo),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (item.duration.isNotEmpty)
                      Text(
                        '⏱ ${item.duration}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.play_circle_fill, color: Colors.indigo, size: 34),
                onTap: () {
                  // Play from this index, passing the full playlist
                  ref.read(audioServiceProvider).playFromPlaylist(items, index);

                  // Open the full player immediately
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AudioPlayerScreen()),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
