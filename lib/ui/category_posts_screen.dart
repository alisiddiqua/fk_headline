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
            child: ListView.separated(
              itemCount: posts.length + 1,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  final notifier = ref.read(postsProvider(category.id).notifier);
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
                          : const Text('Load More Category News', style: TextStyle(fontSize: 16)),
                    ),
                  );
                }
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
