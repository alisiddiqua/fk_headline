import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'widgets/post_card.dart';
import 'category_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsyncValue = ref.watch(postsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('FK Headline', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to Search Screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryScreen()),
              );
            },
          ),
        ],
      ),
      body: postsAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(postsProvider(null));
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load news: $err')),
      ),
    );
  }
}
