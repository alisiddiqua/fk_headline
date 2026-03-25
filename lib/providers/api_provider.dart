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

final postsProvider = FutureProvider.family<List<WPPost>, int?>((ref, categoryId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchPosts(page: 1, categoryId: categoryId);
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
