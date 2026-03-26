import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final youtubeServiceProvider = Provider<YoutubeService>((ref) {
  return YoutubeService(Dio());
});

final shortsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.watch(youtubeServiceProvider);
  return service.fetchShorts();
});

class YoutubeService {
  final Dio _dio;
  final String _apiKey = 'AIzaSyD3Vs3jLRDvpDiJy4tQtKf3ygqUZhhYmQg';
  final String _channelHandle = 'FikrokhabarTV';

  YoutubeService(this._dio);

  Future<List<dynamic>> fetchShorts() async {
    try {
      // 1. Get Channel ID from Handle using YouTube Data API v3
      final channelRes = await _dio.get(
        'https://www.googleapis.com/youtube/v3/channels',
        queryParameters: {
          'part': 'id',
          'forHandle': _channelHandle,
          'key': _apiKey,
        },
      );

      if (channelRes.data['items'] == null || channelRes.data['items'].isEmpty) {
        throw Exception('Channel not found');
      }

      final channelId = channelRes.data['items'][0]['id'];

      // 2. Fetch recent shorts (videos specifically tagged with #shorts)
      final searchRes = await _dio.get(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'q': '#shorts',
          'type': 'video',
          'maxResults': 15,
          'order': 'date',
          'key': _apiKey,
        },
      );

      return searchRes.data['items'];
    } catch (e) {
      throw Exception('Failed to load YouTube Shorts: $e');
    }
  }
}
