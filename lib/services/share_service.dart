import 'package:share_plus/share_plus.dart';
import '../models/post.dart';

class ShareService {
  static Future<void> shareArticle(WPPost post) async {
    final String text = 'Read this breaking news: ${post.title.replaceAll('&#8217;', "'").replaceAll('&#8216;', "'")}! Visit FK Headline App.';
    
    // We now use the fully native share_plus package which pops the standard Android/iOS share sheet!
    await Share.share(text);
  }
}
