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
              itemCount: posts.length,
              separatorBuilder: (context, index) {
                if (index == 0) return const SizedBox(height: 16);
                return const Divider(height: 1);
              },
              itemBuilder: (context, index) {
                // The first post is rendered as a large featured card
                return PostCard(
                  post: posts[index],
                  isFeatured: index == 0,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('Error loading news')),
      ),
    );
  }
}
