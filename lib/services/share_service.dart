import 'package:url_launcher/url_launcher.dart';
import '../models/post.dart';

class ShareService {
  static Future<void> shareArticle(WPPost post) async {
    // For native share sheets, use `package:share_plus`:
    // Share.share('Check out this news: ${post.title} at ${post.featuredMediaUrl ?? ""}');
    
    // Fallback using url_launcher:
    final String text = Uri.encodeComponent('Read this breaking news: ${post.title.replaceAll('&#8217;', "'").replaceAll('&#8216;', "'")}! Visit FK Headline App.');
    final Uri url = Uri.parse('whatsapp://send?text=$text');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Print or fallback if whatsapp is unavailable
      print("Could not launch share link");
    }
  }
}
