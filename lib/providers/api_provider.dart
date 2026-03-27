import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import '../models/category.dart';

// ─── Global Language State ────────────────────────────────────────────────────
enum AppLanguage { english, urdu }

final appLanguageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.english);

final baseUrlProvider = Provider<String>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return lang == AppLanguage.urdu
      ? 'https://fikrokhabar.com/wp-json/wp/v2'
      : 'https://english.fikrokhabar.com/wp-json/wp/v2';
});

// ─── Core Providers ────────────────────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) => Dio());

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ref.watch(baseUrlProvider);
  return ApiService(dio, baseUrl: baseUrl);
});

// ─── Navigation State (used to pause video on tab change) ─────────────────────
final currentTabProvider = StateProvider<int>((ref) => 0);

// ─── Posts Notifier ───────────────────────────────────────────────────────────
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
    // Re-fetches whenever language switches automatically
    ref.watch(appLanguageProvider);
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
      final newPosts = await apiService.fetchPosts(page: _currentPage, categoryId: arg);

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

// ─── Categories & Search ───────────────────────────────────────────────────────
final categoriesProvider = FutureProvider<List<WPCategory>>((ref) async {
  // Reactively re-fetches when language changes
  ref.watch(appLanguageProvider);
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchCategories();
});

final searchProvider = FutureProvider.family<List<WPPost>, String>((ref, query) async {
  if (query.isEmpty) return [];
  ref.watch(appLanguageProvider);
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchPosts(page: 1, searchQuery: query);
});
