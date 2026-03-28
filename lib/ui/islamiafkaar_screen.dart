import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/islamiafkaar_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/audio_service.dart';
import 'widgets/audio_mini_player.dart';

class IslamiafkaarScreen extends ConsumerStatefulWidget {
  const IslamiafkaarScreen({super.key});

  @override
  ConsumerState<IslamiafkaarScreen> createState() => _IslamiafkaarScreenState();
}

class _IslamiafkaarScreenState extends ConsumerState<IslamiafkaarScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(islamiafkaarProvider.notifier).loadMore();
    }
  }

  void _shareAudio(PodcastItem item) {
    final message = '''
🎙️ Listen to *${item.speakerName}* on *"${item.title}"*
🔗 ${item.link}

📲 Download *FK Headline* for more:
https://play.google.com/store/apps/details?id=com.fikrokhabar.fkheadline
''';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
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
          final notifier = ref.watch(islamiafkaarProvider.notifier);

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(islamiafkaarProvider);
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 140),
              itemCount: items.length + 1,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  if (!notifier.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                          child: Text('All audio recordings loaded',
                              style: TextStyle(color: Colors.grey))),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

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
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.speakerName.isNotEmpty)
                        Text(
                          item.speakerName,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.indigo),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (item.duration.isNotEmpty)
                        Text(
                          '⏱ ${item.duration}',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.grey, size: 20),
                        onPressed: () => _shareAudio(item),
                      ),
                      const Icon(Icons.play_circle_fill,
                        color: Colors.indigo, size: 30),
                    ],
                  ),
                  onTap: () {
                    ref.read(audioServiceProvider).playFromPlaylist(items, index);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AudioPlayerScreen()),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
