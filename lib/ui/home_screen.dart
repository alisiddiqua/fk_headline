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
    final language = ref.watch(appLanguageProvider);
    final isUrdu = language == AppLanguage.urdu;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 28),
            const SizedBox(width: 10),
            Text(
              isUrdu ? 'FK اردو خبریں' : 'FK Headline',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Language toggle button — replaces old YouTube icon
          GestureDetector(
            onTap: () {
              final newLang = isUrdu ? AppLanguage.english : AppLanguage.urdu;
              ref.read(appLanguageProvider.notifier).state = newLang;
              // Invalidate all posts & categories to reload with new endpoint
              ref.invalidate(postsProvider(null));
              ref.invalidate(categoriesProvider);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isUrdu ? Colors.green : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isUrdu ? 'English' : 'اردو خبریں',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 26),
            onPressed: () async {
              final base = isUrdu ? 'https://fikrokhabar.com' : 'https://english.fikrokhabar.com';
              final Uri url = Uri.parse('$base/whatsapp');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint(e.toString());
              }
            },
          ),
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
                      child: Center(
                        child: Text('You have reached the end',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => notifier.loadMore(),
                      child: postsAsyncValue.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              isUrdu ? 'مزید خبریں لوڈ کریں' : 'Load More News',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  );
                }

                return PostCard(post: posts[index], isFeatured: index == 0);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading news: $error')),
      ),
    );
  }
}
