import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/story.dart';

/// Opens an article link, respecting the user's in-app vs. external browser
/// preference — same behavior as the Cordova InAppBrowser toggle before.
Future<void> openStoryLink(Story story, {required bool openInApp}) async {
  final uri = Uri.tryParse(story.url);
  if (uri == null || uri.scheme != 'https') return;

  await launchUrl(
    uri,
    mode: openInApp ? LaunchMode.inAppBrowserView : LaunchMode.externalApplication,
  );
}

Future<void> shareStory(Story story) async {
  await Share.share('${story.title}\n${story.url}');
}
