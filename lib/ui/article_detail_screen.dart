import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import '../providers/bookmark_provider.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final WPPost post;

  const ArticleDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarkedAsync = ref.watch(isBookmarkedProvider(post.id));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality available with native extension')),
              );
            },
          ),
          isBookmarkedAsync.when(
            data: (isBookmarked) => IconButton(
              icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
              onPressed: () async {
                final service = ref.read(bookmarkServiceProvider);
                if (isBookmarked) {
                  await service.removeBookmark(post.id);
                } else {
                  await service.saveBookmark(post);
                }
                ref.invalidate(isBookmarkedProvider(post.id));
                ref.invalidate(bookmarksProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isBookmarked ? 'Removed from bookmarks' : 'Saved to bookmarks')),
                );
              },
            ),
            loading: () => const IconButton(icon: Icon(Icons.bookmark_border), onPressed: null),
            error: (_, __) => const IconButton(icon: Icon(Icons.error), onPressed: null),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.featuredMediaUrl != null)
              CachedNetworkImage(
                imageUrl: post.featuredMediaUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  height: 250,
                  child: Center(child: Icon(Icons.broken_image, size: 50)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title.replaceAll('&#8216;', "'").replaceAll('&#8217;', "'").replaceAll('&#8220;', '"').replaceAll('&#8221;', '"'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Published on ${post.date.substring(0, 10)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Html(
                    data: post.content,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
