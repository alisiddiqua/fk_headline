import 'package:dio/dio.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../core/constants.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<List<WPPost>> fetchPosts({int page = 1, int? categoryId, String? searchQuery}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.postsEndpoint}',
        queryParameters: {
          'page': page,
          'per_page': 8, // Reduced from 10 to instantly lower MySQL thread locks.
          // _embed removed completely to prevent 503 CPU crashes.
          if (categoryId != null) 'categories': categoryId,
          if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
        },
      );

      if (response.statusCode == 200) {
        List data = response.data;
        List<WPPost> posts = data.map((json) => WPPost.fromJson(json)).toList();

        // Fetch media sequentially only if needed. Because we reduced per_page to 8, 
        // this is mathematically massively lighter on the 1GB memory cap.
        for (int i = 0; i < posts.length; i++) {
          if (posts[i].featuredMediaId != 0) {
            String? mediaUrl = await fetchMediaUrl(posts[i].featuredMediaId);
            posts[i] = posts[i].copyWith(featuredMediaUrl: mediaUrl);
          }
        }
        return posts;
      } else {
        throw Exception('Failed to load posts statusCode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  Future<String?> fetchMediaUrl(int mediaId) async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}${ApiConstants.mediaEndpoint}/$mediaId');
      if (response.statusCode == 200) {
        return response.data['source_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<WPCategory>> fetchCategories() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}',
        queryParameters: {'per_page': 15, 'hide_empty': true},
      );

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => WPCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
