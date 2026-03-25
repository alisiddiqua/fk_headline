import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'widgets/post_card.dart';
import '../models/category.dart';

class CategoryPostsScreen extends ConsumerWidget {
  final WPCategory category;

  const CategoryPostsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsyncValue = ref.watch(postsProvider(category.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name.replaceAll(RegExp(r'&amp;'), '&')),
      ),
      body: postsAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found in this category.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(postsProvider(category.id));
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
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
