import 'package:dio/dio.dart';
import '../models/post.dart';
import '../models/category.dart';

class ApiService {
  final Dio _dio;
  final String _baseUrl;

  ApiService(this._dio, {required String baseUrl}) : _baseUrl = baseUrl;

  Future<List<WPPost>> fetchPosts({int page = 1, int? categoryId, String? searchQuery}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/posts',
        queryParameters: {
          'page': page,
          'per_page': 8,
          '_fields': 'id,title,excerpt,date,categories,author,featured_media,link,slug',
          if (categoryId != null) 'categories': categoryId,
          if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        List<WPPost> posts = data.map((json) => WPPost.fromJson(json)).toList();

        // ─── BATCH MEDIA FETCH (2 API calls total instead of N+1) ───
        final mediaIds = posts
            .where((p) => p.featuredMediaId != 0)
            .map((p) => p.featuredMediaId)
            .toSet()
            .toList();

        if (mediaIds.isNotEmpty) {
          final mediaMap = await _fetchMediaBatch(mediaIds);
          posts = posts.map((post) {
            if (post.featuredMediaId != 0 && mediaMap.containsKey(post.featuredMediaId)) {
              return post.copyWith(featuredMediaUrl: mediaMap[post.featuredMediaId]);
            }
            return post;
          }).toList();
        }

        return posts;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  /// Fetches ALL media in a single request by passing a comma-separated list of IDs.
  /// This replaces the old sequential N-requests loop.
  Future<Map<int, String?>> _fetchMediaBatch(List<int> ids) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/media',
        queryParameters: {
          'include': ids.join(','),
          'per_page': ids.length,
          '_fields': 'id,source_url',
        },
      );
      if (response.statusCode == 200) {
        final Map<int, String?> result = {};
        for (final item in response.data) {
          result[item['id'] as int] = item['source_url'] as String?;
        }
        return result;
      }
    } catch (_) {}
    return {};
  }

  Future<List<WPCategory>> fetchCategories() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/categories',
        queryParameters: {'per_page': 15, 'hide_empty': true},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => WPCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
