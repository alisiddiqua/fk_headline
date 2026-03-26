import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'widgets/post_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsyncValue = ref.watch(postsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 28),
            const SizedBox(width: 10),
            const Text('FK Headline', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.youtube, color: Colors.red, size: 26),
            onPressed: () async {
              final Uri url = Uri.parse('https://www.youtube.com/results?search_query=Fikrokhabar+Shorts');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint(e.toString());
              }
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 26),
            onPressed: () async {
              final Uri url = Uri.parse('https://english.fikrokhabar.com/whatsapp');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint(e.toString());
              }
            },
          )
        ],
      ),
      body: postsAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No news found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(postsProvider(null));
            },
            child: ListView.separated(
              itemCount: posts.length + 1,
              separatorBuilder: (context, index) {
                if (index == 0) return const SizedBox(height: 16);
                return const Divider(height: 1);
              },
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  final notifier = ref.read(postsProvider(null).notifier);
                  if (!notifier.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('You have reached the end', style: TextStyle(color: Colors.grey))),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => notifier.loadMore(),
                      child: postsAsyncValue.isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Load More News', style: TextStyle(fontSize: 16)),
                    ),
                  );
                }
                
                return PostCard(
                  post: posts[index],
                  isFeatured: index == 0,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading news: $error')),
      ),
    );
  }
}
