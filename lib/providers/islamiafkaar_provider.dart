import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastItem {
  final String title;
  final String link;
  final String audioUrl;
  final String speakerName; // from <description> tag
  final String duration;    // from <itunes:duration> tag
  final String pubDate;
  final String? imageUrl;

  PodcastItem({
    required this.title,
    required this.link,
    required this.audioUrl,
    required this.speakerName,
    required this.duration,
    required this.pubDate,
    this.imageUrl,
  });
}

class IslamiafkaarNotifier extends AsyncNotifier<List<PodcastItem>> {
  int _page = 1;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  @override
  Future<List<PodcastItem>> build() async {
    _page = 1;
    _hasMoreData = true;
    return _fetchPage(_page);
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMoreData) return;
    
    // Temporarily set loading state to true without losing current data
    state = const AsyncLoading<List<PodcastItem>>().copyWithPrevious(state);
    
    try {
      _page++;
      final newItems = await _fetchPage(_page);
      
      if (newItems.isEmpty) {
        _hasMoreData = false;
      }
      
      state = AsyncData([...state.value ?? [], ...newItems]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<List<PodcastItem>> _fetchPage(int page) async {
    final response = await http.get(Uri.parse('https://islamiafkaar.com/feed/podcast/?paged=$page'));

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      return items.map((node) {
        final title = node.findElements('title').firstOrNull?.innerText
            .replaceAll('&#8211;', '–')
            .replaceAll('&amp;', '&') ?? 'Unknown Title';
        final link = node.findElements('link').firstOrNull?.innerText ?? '';
        final pubDate = node.findElements('pubDate').firstOrNull?.innerText ?? '';

        final rawDescription = node.findElements('description').firstOrNull?.innerText ?? '';
        final speakerName = rawDescription.replaceAll(RegExp(r'<[^>]*>'), '').trim();

        final duration = node.findAllElements('duration').firstOrNull?.innerText ?? '';

        final enclosure = node.findElements('enclosure').firstOrNull;
        final audioUrl = enclosure?.getAttribute('url') ?? '';

        final itunesImage = node.findAllElements('image').firstOrNull;
        final imageUrl = itunesImage?.getAttribute('href');

        return PodcastItem(
          title: title,
          link: link,
          audioUrl: audioUrl,
          speakerName: speakerName,
          duration: duration,
          pubDate: pubDate,
          imageUrl: imageUrl,
        );
      }).toList();
    } else if (response.statusCode == 404) {
      // 404 usually means no more pages in wordpress rss
      _hasMoreData = false;
      return [];
    } else {
      throw Exception('Failed to load Islamiafkaar feed');
    }
  }
}

final islamiafkaarProvider = AsyncNotifierProvider<IslamiafkaarNotifier, List<PodcastItem>>(() {
  return IslamiafkaarNotifier();
});
