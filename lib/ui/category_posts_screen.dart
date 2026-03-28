import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'widgets/post_card.dart';
import '../models/category.dart';

class CategoryPostsScreen extends ConsumerStatefulWidget {
  final WPCategory category;

  const CategoryPostsScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryPostsScreen> createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends ConsumerState<CategoryPostsScreen> {
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
      ref.read(postsProvider(widget.category.id).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsyncValue = ref.watch(postsProvider(widget.category.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name.replaceAll(RegExp(r'&amp;'), '&')),
      ),
      body: postsAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found in this category.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(postsProvider(widget.category.id));
            },
            child: ListView.separated(
              controller: _scrollController,
              itemCount: posts.length + 1,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  final notifier = ref.watch(postsProvider(widget.category.id).notifier);
                  if (!notifier.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                          child: Text('You have reached the end',
                              style: TextStyle(color: Colors.grey))),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
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
