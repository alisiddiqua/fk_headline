import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'category_posts_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final isUrdu = ref.watch(appLanguageProvider) == AppLanguage.urdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'Urdu Categories' : 'Categories'),
      ),
      body: categoriesAsyncValue.when(
        data: (categories) {
          if (categories.isEmpty) {
             return const Center(child: Text('No categories found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(categoriesProvider);
            },
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = categories[index];
                final icon = _getCategoryIcon(category.name);
                
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(
                    category.name.replaceAll(RegExp(r'&amp;'), '&'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${category.count}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      )
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPostsScreen(category: category),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('world') || lowerName.contains('عالمی')) return FontAwesomeIcons.globe;
    if (lowerName.contains('india') || lowerName.contains('قومی')) return FontAwesomeIcons.flag;
    if (lowerName.contains('sports') || lowerName.contains('کھیل')) return FontAwesomeIcons.trophy;
    if (lowerName.contains('health') || lowerName.contains('صحت')) return FontAwesomeIcons.heartPulse;
    if (lowerName.contains('education') || lowerName.contains('تعلیمی')) return FontAwesomeIcons.graduationCap;
    if (lowerName.contains('karnataka') || lowerName.contains('کرناٹک')) return FontAwesomeIcons.mapLocation;
    if (lowerName.contains('editorial') || lowerName.contains('اداریہ')) return FontAwesomeIcons.penNib;
    if (lowerName.contains('column') || lowerName.contains('کالم')) return FontAwesomeIcons.newspaper;
    if (lowerName.contains('women') || lowerName.contains('خواتین')) return FontAwesomeIcons.personDress;
    if (lowerName.contains('kids') || lowerName.contains('بچوں')) return FontAwesomeIcons.child;
    if (lowerName.contains('special') || lowerName.contains('خصوصی')) return FontAwesomeIcons.star;
    return FontAwesomeIcons.folderOpen;
  }
}
