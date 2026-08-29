import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'privacy_policy_page.dart';

/// About screen — what the app is, what it's built with, and how to reach
/// the developer. Mirrors the structure of Global Climate News's About page.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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

  Future<void> _emailDeveloper() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'rabolista@gmail.com',
      query: 'subject=${Uri.encodeComponent('Tech and Feeds')}',
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1B4C), Color(0xFF00B4D8)],
                ),
              ),
              child: const Icon(Icons.podcasts_rounded,
                  color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Tech and Feeds',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (_version.isNotEmpty)
            Center(
              child: Text('Version $_version', style: theme.textTheme.bodySmall),
            ),
          const SizedBox(height: 24),
          Text(
            'Tech and Feeds pulls live technology headlines from Hacker News '
            'into one clean, easy-to-read feed. No account, no ads, no '
            'clutter.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'What it does',
            bullets: const [
              'Live feed of the newest stories, straight from Hacker News.',
              'Browse by topic: Apple, Android, AI, and Security.',
              'Search headlines by keyword.',
              'Pull to refresh and infinite scroll for older stories.',
              'Save articles to read later, even offline.',
              'Share any headline with the native share sheet.',
              'Choose to open links inside the app or your default browser.',
              'Light & dark mode, matching your device theme.',
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'What it\'s built with',
            bullets: const [
              'Framework: Flutter (Dart) — one codebase for iOS and Android.',
              'Data source: the public Hacker News Algolia Search API.',
              'No backend/server required.',
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text('Contact the developer'),
            subtitle: const Text('rabolista@gmail.com'),
            onTap: _emailDeveloper,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Made by Robert Allan Bolista',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.bullets});

  final String title;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final bullet in bullets)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(bullet)),
              ],
            ),
          ),
      ],
    );
  }
}
