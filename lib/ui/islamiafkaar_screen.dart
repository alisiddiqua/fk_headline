import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/islamiafkaar_provider.dart';
import '../services/audio_service.dart';

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
            padding: const EdgeInsets.only(bottom: 100), // Space for mini-player
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => const Icon(Icons.music_note),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: const Icon(Icons.mic, color: Colors.grey),
                        ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.pubDate.length > 20 ? item.pubDate.substring(0, 16) : item.pubDate,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.play_circle_fill, color: Colors.indigo, size: 30),
                onTap: () {
                  ref.read(audioServiceProvider).play(
                        item.audioUrl,
                        title: item.title,
                        artist: "Islamiafkaar",
                      );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
