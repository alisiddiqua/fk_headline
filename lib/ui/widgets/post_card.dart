import 'package:flutter/material.dart';
import '../../models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../article_detail_screen.dart';

class PostCard extends StatelessWidget {
  final WPPost post;
  final bool isFeatured;

  const PostCard({super.key, required this.post, this.isFeatured = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArticleDetailScreen(post: post)),
        );
      },
      child: isFeatured ? _buildFeaturedLayout(context) : _buildStandardLayout(context),
    );
  }

  Widget _buildFeaturedLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.featuredMediaUrl != null)
          CachedNetworkImage(
            imageUrl: post.featuredMediaUrl!,
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(height: 240, color: Colors.grey[200]),
            errorWidget: (context, url, err) => Container(height: 240, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title.replaceAll('&#8216;', "'").replaceAll('&#8217;', "'").replaceAll('&#8220;', '"').replaceAll('&#8221;', '"'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              if (post.subHeadline.isNotEmpty)
                Text(
                  post.subHeadline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text(
                    post.authorName.isNotEmpty ? post.authorName : "Fikrokhabar",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text(
                    post.date.length >= 10 ? post.date.substring(0, 10) : post.date,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandardLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title.replaceAll('&#8216;', "'").replaceAll('&#8217;', "'").replaceAll('&#8220;', '"').replaceAll('&#8221;', '"'),
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  post.date.length >= 10 ? post.date.substring(0, 10) : post.date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (post.featuredMediaUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: post.featuredMediaUrl!,
                height: 90,
                width: 110,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(height: 90, width: 110, color: Colors.grey[200]),
                errorWidget: (context, url, err) => Container(height: 90, width: 110, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
            )
          else
            Container(
              height: 90,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.article, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
