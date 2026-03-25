import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'category_posts_screen.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
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
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(
                    category.name.replaceAll(RegExp(r'&amp;'), '&'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.count}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
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
}
