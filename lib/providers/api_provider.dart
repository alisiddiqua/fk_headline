import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import '../models/category.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});

class PostsNotifier extends FamilyAsyncNotifier<List<WPPost>, int?> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetching = false;
  
  bool get hasMore => _hasMore;

  @override
  Future<List<WPPost>> build(int? categoryId) async {
    _currentPage = 1;
    _hasMore = true;
    _isFetching = false;
    final apiService = ref.watch(apiServiceProvider);
    return apiService.fetchPosts(page: _currentPage, categoryId: categoryId);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isFetching || state.isLoading) return;
    
    _isFetching = true;
    state = const AsyncLoading<List<WPPost>>().copyWithPrevious(state);

    try {
      final apiService = ref.read(apiServiceProvider);
      _currentPage++;
      final newPosts = await apiService.fetchPosts(page: _currentPage, categoryId: this.arg);
      
      final currentPosts = state.valueOrNull ?? [];
      if (newPosts.isEmpty) {
        _hasMore = false;
        state = AsyncData(currentPosts);
      } else {
        state = AsyncData([...currentPosts, ...newPosts]);
      }
    } catch (e, st) {
      state = AsyncError<List<WPPost>>(e, st).copyWithPrevious(state);
    } finally {
      _isFetching = false;
    }
  }
}

final postsProvider = AsyncNotifierProviderFamily<PostsNotifier, List<WPPost>, int?>(() {
  return PostsNotifier();
});

final categoriesProvider = FutureProvider<List<WPCategory>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchCategories();
});

final searchProvider = FutureProvider.family<List<WPPost>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchPosts(page: 1, searchQuery: query);
});
