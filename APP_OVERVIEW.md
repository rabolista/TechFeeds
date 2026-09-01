# Tech and Feeds — What This App Is

A simple explanation of the app, for when someone asks "what does it do?"

## The elevator pitch

Tech and Feeds is a mobile app (iOS & Android) that pulls together live
technology headlines from Hacker News into one clean, easy-to-read feed.
No account, no ads, no clutter.

## What it does

- **Live news feed**: Pulls real, current tech stories directly from the
  public Hacker News (Algolia) Search API — not made-up or hardcoded content.
- **Browse by topic**: Filter stories by category (Apple, Android, AI,
  Security), matched by keywords in the headline.
- **Search**: Quickly find stories by keyword.
- **Pull to refresh**: Swipe down on the feed to check for the newest stories.
- **Infinite scroll**: Keep scrolling to load older stories, page by page.
- **Save for later**: Bookmark any headline to read again, even offline.
- **Share**: Share a headline and its link using the native share sheet.
- **Open your way**: Choose to open article links inside the app or in your
  device's default browser (Settings tab).
- **Light & dark mode**: Matches your device theme, or toggle manually.
- **About & Privacy Policy**: Built-in pages explaining what the app is, what
  it's built with, and how your data is (and isn't) used.

## Who it's for

Anyone who wants a fast, no-nonsense way to keep up with tech news without
digging through multiple sites or apps.

## What it's built with

- **Framework**: Flutter (Dart) — one codebase that runs natively on both
  iOS and Android.
- **Data source**: The public Hacker News Algolia Search API
  (`hn.algolia.com`).
- **No backend/server required**: The app talks directly to that public API;
  there's no custom server to maintain.
- **Local storage only**: Saved articles and preferences (theme, link-opening
  mode) are stored on-device via `shared_preferences`. No account or cloud
  sync.

## App identity

- **Name**: Tech and Feeds
- **Bundle ID**: `com.ionicframework.techfeed247968`
- **Apple ID**: 1030689511
- **SKU**: techandfeeds
- **Version**: 1.5.1 (build 41)

## History

This app is a full native rewrite (Flutter, iOS & Android) of an earlier
Ionic/Cordova app of the same name and bundle ID (previously at version
0.0.6 on the App Store). The UI design language — theming, cards, filter
chips, and page layout — is shared with the "Global Climate News" Flutter
app, adapted here with a tech-blue color palette and a feed/signal app icon
instead of the climate app's green globe icon.

## Project structure

```
lib/
  main.dart                 App entry point, theme mode persistence
  theme/                    Material 3 theme + per-category colors/icons
  models/                   Story and StoryCategory data models
  services/                 HnService — talks to the HN Algolia API
  data/                     SharedPreferences-backed saved-stories/settings storage
  state/                    ChangeNotifier controllers shared across tabs
  screens/                  Feed (home), Saved, Settings, About, Privacy Policy
  widgets/                  StoryCard, CategoryFilterBar
  utils/                    Date formatting, link-opening/share helpers
```

## Where things live

- App icon source: `assets/icon/icon.png`, `assets/icon/icon_foreground.png`
  (regenerate with `python3 tool/generate_icon.py` then
  `dart run flutter_launcher_icons`).
- Privacy policy: [PRIVACY_POLICY.md](PRIVACY_POLICY.md) (also shown in-app
  under About → Privacy Policy).
