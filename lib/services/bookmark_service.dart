import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';

class BookmarkService {
  static const String _bookmarkKey = 'bookmarked_posts';

  Future<List<WPPost>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarksJson = prefs.getStringList(_bookmarkKey) ?? [];
    return bookmarksJson.map((jsonStr) {
      final jsonMap = jsonDecode(jsonStr);
      return WPPost.fromJson(jsonMap);
    }).toList();
  }

  Future<void> saveBookmark(WPPost post) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarksJson = prefs.getStringList(_bookmarkKey) ?? [];
    
    // Check if already exists
    if (!bookmarksJson.any((jsonStr) => jsonDecode(jsonStr)['id'] == post.id)) {
      final postMap = post.toJson();
      bookmarksJson.add(jsonEncode(postMap));
      await prefs.setStringList(_bookmarkKey, bookmarksJson);
    }
  }

  Future<void> removeBookmark(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarksJson = prefs.getStringList(_bookmarkKey) ?? [];
    
    bookmarksJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['id'] == postId);
    await prefs.setStringList(_bookmarkKey, bookmarksJson);
  }

  Future<bool> isBookmarked(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarksJson = prefs.getStringList(_bookmarkKey) ?? [];
    return bookmarksJson.any((jsonStr) => jsonDecode(jsonStr)['id'] == postId);
  }
}
