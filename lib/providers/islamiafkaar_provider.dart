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
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetching = false;

  bool get hasMore => _hasMore;

  @override
  Future<List<PodcastItem>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isFetching = false;
    return _fetchPage(_currentPage);
  }

  Future<List<PodcastItem>> _fetchPage(int page) async {
    final url = page == 1
        ? 'https://islamiafkaar.com/feed/podcast/'
        : 'https://islamiafkaar.com/feed/podcast/?paged=$page';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      return items.map((node) {
        final title = node.findElements('title').first.innerText
            .replaceAll('&#8211;', '–')
            .replaceAll('&amp;', '&');
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
    } else {
      return []; // Return empty if page not found
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isFetching || state.isLoading) return;

    _isFetching = true;
    try {
      _currentPage++;
      final newItems = await _fetchPage(_currentPage);

      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        final currentItems = state.valueOrNull ?? [];
        state = AsyncData([...currentItems, ...newItems]);
      }
    } catch (e, st) {
      state = AsyncError<List<PodcastItem>>(e, st).copyWithPrevious(state);
    } finally {
      _isFetching = false;
    }
  }
}

final islamiafkaarProvider = AsyncNotifierProvider<IslamiafkaarNotifier, List<PodcastItem>>(() {
  return IslamiafkaarNotifier();
});
