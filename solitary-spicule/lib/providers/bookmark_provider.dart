import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bookmark_service.dart';
import '../models/post.dart';

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

final bookmarksProvider = FutureProvider<List<WPPost>>((ref) async {
  final service = ref.watch(bookmarkServiceProvider);
  return service.getBookmarks();
});

final isBookmarkedProvider = FutureProvider.family<bool, int>((ref, postId) async {
  final service = ref.watch(bookmarkServiceProvider);
  return service.isBookmarked(postId);
});
