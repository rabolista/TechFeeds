import 'package:flutter/material.dart';

/// In-app privacy policy, mirrored from PRIVACY_POLICY.md so it's always
/// reachable without needing a network connection.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sections = <(String, String)>[
    (
      '1. Information We Collect',
      'We do not require account registration. We do not directly collect '
          'personal information such as your name, email address, phone '
          'number, contacts, precise location, or payment information.',
    ),
    (
      '2. Information Processed by Third Parties',
      'To function, the app loads public content from external services. '
          'Those services may receive standard technical request data, such '
          'as IP address, device metadata, and request timestamps, handled '
          'according to their own privacy practices.',
    ),
    (
      '3. Third-Party Services',
      'The app connects to hn.algolia.com to retrieve headline data, and to '
          'external websites you choose to open from a headline. Opening an '
          'external link makes you subject to that site\'s own privacy '
          'policy.',
    ),
    (
      '4. Data Use',
      'Network access is used only to retrieve and display news content. We '
          'do not sell personal information.',
    ),
    (
      '5. Data Retention',
      'The app does not maintain user accounts or profile databases. Saved '
          'articles and settings are stored locally on your device and can '
          'be cleared at any time from Settings.',
    ),
    (
      '6. Permissions',
      'The app primarily requires network access to load content. It does '
          'not request sensitive runtime permissions such as contacts, '
          'microphone, camera, or precise location as part of core '
          'functionality.',
    ),
    (
      "7. Children's Privacy",
      'The app is not specifically directed to children under 13.',
    ),
    (
      '8. Security',
      'We use HTTPS endpoints where supported and limit network access to '
          'services required for app functionality.',
    ),
    (
      '9. Changes to This Policy',
      'We may update this policy from time to time. Changes will be posted '
          'with a revised effective date.',
    ),
    (
      '10. Contact',
      'Developer: Robert Allan Bolista\nEmail: rabolista@gmail.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Effective date: 2026-08-29',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tech and Feeds (bundle ID: com.ionicframework.techfeed247968) is '
            'a mobile app that displays public technology news headlines and '
            'lets you open linked articles. This policy explains what '
            'information is, and is not, collected when you use the app.',
          ),
          for (final (title, body) in _sections) ...[
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 6),
            Text(body),
          ],
        ],
      ),
    );
  }
}
