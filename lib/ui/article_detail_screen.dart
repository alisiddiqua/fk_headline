import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import '../providers/bookmark_provider.dart';
import '../services/share_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final WPPost post;

  const ArticleDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarkedAsync = ref.watch(isBookmarkedProvider(post.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: post.featuredMediaUrl != null
                  ? CachedNetworkImage(
                      imageUrl: post.featuredMediaUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                    )
                  : Container(color: Colors.grey[200]),
            ),
            actions: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => ShareService.shareArticle(post),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 8),
                child: isBookmarkedAsync.when(
                  data: (isBookmarked) => IconButton(
                    icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
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
                  loading: () => const IconButton(icon: Icon(Icons.bookmark_border, color: Colors.white), onPressed: null),
                  error: (_, __) => const IconButton(icon: Icon(Icons.error, color: Colors.white), onPressed: null),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title.replaceAll('&#8216;', "'").replaceAll('&#8217;', "'").replaceAll('&#8220;', '"').replaceAll('&#8221;', '"'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 16,
                        child: const Icon(Icons.person, size: 20, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName.isNotEmpty ? post.authorName : "Fikrokhabar",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              post.date.length >= 10 ? post.date.substring(0, 10) : post.date,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  if (post.pdfLink.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Read Full Magazine (PDF)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final Uri url = Uri.parse(post.pdfLink);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
                  Html(
                    data: post.content
                        .replaceAll('data-src-fg=', 'src=')
                        .replaceAll('data-src=', 'src=')
                        .replaceAll('data-lazy-src=', 'src=')
                        .replaceAll(RegExp(r'height="(\d+)"'), ''),
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        fontSize: FontSize(16.0),
                        lineHeight: LineHeight(1.6),
                      ),
                      "p": Style(margin: Margins.only(bottom: 16)),
                      "img": Style(width: Width(100, Unit.percent), height: Height.auto()),
                      ".foogallery img": Style(width: Width(100, Unit.percent), height: Height.auto(), display: Display.block),
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
