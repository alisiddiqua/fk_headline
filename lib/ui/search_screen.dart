import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import 'widgets/post_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _query = '';
              });
            },
          )
        ],
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Enter a keyword to search'))
          : searchResults.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(child: Text('No results found.'));
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: posts[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }
}
