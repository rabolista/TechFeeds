import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'privacy_policy_page.dart';

/// About page: app info, developer credits, and legal links — mirrors the
/// structure of Global Climate News's About page.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key, this.accentColor = const Color(0xFF0B72B9)});

  final Color accentColor;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final Uri _linkedInUrl = Uri.parse(
    'https://www.linkedin.com/in/robert-allan-bolista/',
  );
  final Uri _websiteUrl = Uri.parse('https://www.rabolista.com');

  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = '${info.version} (${info.buildNumber})');
  }

  Future<void> _open(Uri url) async {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Column(
            children: [
              Icon(Icons.rss_feed_rounded, size: 50, color: accentColor),
              const SizedBox(height: 12),
              const Text(
                'Tech and Feeds',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Live technology headlines from Hacker News — curated into '
                  'one clean, fast feed you can filter, search, and save.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
              if (_version.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Version $_version',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),
          const _SectionHeader(title: 'Built With'),
          ListTile(
            leading: Icon(Icons.flutter_dash_rounded, color: accentColor),
            title: const Text('Flutter & Dart'),
            subtitle: const Text(
              "Google's UI toolkit for natively compiled iOS and Android apps",
            ),
          ),
          ListTile(
            leading: Icon(Icons.travel_explore, color: accentColor),
            title: const Text('Hacker News (Algolia Search API)'),
            subtitle: const Text('Public data source — no backend required'),
          ),
          const SizedBox(height: 8),
          const _SectionHeader(title: 'Developer'),
          ListTile(
            leading: Icon(Icons.person, color: accentColor),
            title: const Text('Robert Allan Bolista'),
          ),
          ListTile(
            leading: Icon(Icons.link, color: accentColor),
            title: const Text('LinkedIn Profile'),
            onTap: () => _open(_linkedInUrl),
          ),
          ListTile(
            leading: Icon(Icons.travel_explore, color: accentColor),
            title: const Text('Website'),
            onTap: () => _open(_websiteUrl),
          ),
          const SizedBox(height: 8),
          const _SectionHeader(title: 'Legal'),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: accentColor),
            title: const Text('Privacy Policy'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
