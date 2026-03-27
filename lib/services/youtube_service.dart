import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final youtubeServiceProvider = Provider<YoutubeService>((ref) {
  return YoutubeService(Dio());
});

class ShortsNotifier extends AsyncNotifier<List<dynamic>> {
  String? _nextPageToken;
  bool _isFetching = false;
  String? _channelId;

  @override
  Future<List<dynamic>> build() async {
    _nextPageToken = null;
    _isFetching = false;
    final service = ref.watch(youtubeServiceProvider);
    
    // 1. Get Channel ID
    _channelId = await service.getChannelId();
    
    // 2. Fetch first page
    final result = await service.fetchVideos(_channelId!, null);
    _nextPageToken = result['nextPageToken'];
    return result['items'];
  }

  Future<void> loadMore() async {
    // If we're already loading, or there's no more pages, cancel the call smoothly
    if (_nextPageToken == null || _isFetching || _channelId == null || state.isLoading) return;
    
    _isFetching = true;
    try {
      final service = ref.read(youtubeServiceProvider);
      final result = await service.fetchVideos(_channelId!, _nextPageToken);
      
      _nextPageToken = result['nextPageToken'];
      final newItems = result['items'] as List<dynamic>;
      
      final currentList = state.valueOrNull ?? [];
      
      // Prevent UI tearing by softly appending state
      state = AsyncData([...currentList, ...newItems]);
    } catch (e) {
      // Gracefully fail page loads without blanking previous videos
    } finally {
      _isFetching = false;
    }
  }
}

final shortsProvider = AsyncNotifierProvider<ShortsNotifier, List<dynamic>>(() {
  return ShortsNotifier();
});

class YoutubeService {
  final Dio _dio;
  final String _apiKey = 'AIzaSyD3Vs3jLRDvpDiJy4tQtKf3ygqUZhhYmQg';
  final String _channelHandle = 'FikrokhabarTV'; // Dynamic targeting

  YoutubeService(this._dio);

  Future<String> getChannelId() async {
    final channelRes = await _dio.get(
      'https://www.googleapis.com/youtube/v3/channels',
      queryParameters: {
        'part': 'id',
        'forHandle': _channelHandle,
        'key': _apiKey,
      },
    );

    if (channelRes.data['items'] == null || channelRes.data['items'].isEmpty) {
      throw Exception('Channel not found via handle.');
    }
    return channelRes.data['items'][0]['id'];
  }

  Future<Map<String, dynamic>> fetchVideos(String channelId, String? pageToken) async {
    final query = {
      'part': 'snippet',
      'channelId': channelId,
      'type': 'video',
      'videoDuration': 'short',
      'maxResults': 15,
      'order': 'date',
      'key': _apiKey,
    };
    if (pageToken != null) {
      query['pageToken'] = pageToken;
    }

    final searchRes = await _dio.get(
      'https://www.googleapis.com/youtube/v3/search',
      queryParameters: query,
    );

    return {
      'items': searchRes.data['items'] ?? [],
      'nextPageToken': searchRes.data['nextPageToken'],
    };
  }
}
