import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'widgets/post_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
      ref.read(postsProvider(null).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsyncValue = ref.watch(postsProvider(null));
    final language = ref.watch(appLanguageProvider);
    final isUrdu = language == AppLanguage.urdu;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 28),
            const SizedBox(width: 10),
            const Text(
              'FK Headline',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              final newLang = isUrdu ? AppLanguage.english : AppLanguage.urdu;
              ref.read(appLanguageProvider.notifier).state = newLang;
              ref.invalidate(postsProvider(null));
              ref.invalidate(categoriesProvider);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isUrdu ? Colors.green.shade600 : Colors.deepOrange,
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
              final url = isUrdu
                  ? 'https://whatsapp.com/channel/0029VaoBbwMHltY4b5JNim2x'
                  : 'https://whatsapp.com/channel/0029VbApX7vGJP8HGgsiib2J';
              final Uri uri = Uri.parse(url);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
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
              ref.refresh(postsProvider(null));
            },
            child: ListView.separated(
              controller: _scrollController,
              itemCount: posts.length + (ref.watch(postsProvider(null).notifier).hasMore ? 1 : 1),
              separatorBuilder: (context, index) {
                if (index == 0) return const SizedBox(height: 16);
                return const Divider(height: 1);
              },
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  final notifier = ref.watch(postsProvider(null).notifier);
                  if (!notifier.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text('You have reached the end',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
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
