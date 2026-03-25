import 'package:share_plus/share_plus.dart';
import '../models/post.dart';

class ShareService {
  static Future<void> shareArticle(WPPost post) async {
    final String headline = post.title.replaceAll('&#8216;', "'").replaceAll('&#8217;', "'").replaceAll('&#8220;', '"').replaceAll('&#8221;', '"');
    final String sub = post.subHeadline;
    
    final String text = '*$headline*\n\n_$sub_\n\nRead This: ${post.shortLink}\n\nDownload FK Headline: https://english.fikrokhabar.com/download';
    
    await Share.share(text);
  }
}
