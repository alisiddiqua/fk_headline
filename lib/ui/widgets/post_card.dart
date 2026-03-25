import 'package:flutter/material.dart';
import '../../models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../article_detail_screen.dart';

class PostCard extends StatelessWidget {
  final WPPost post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(post: post),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.featuredMediaUrl != null)
              CachedNetworkImage(
                imageUrl: post.featuredMediaUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  height: 200,
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.excerpt.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
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
