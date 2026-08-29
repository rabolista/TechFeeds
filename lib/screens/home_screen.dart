import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/feed_cache_store.dart';
import '../models/story.dart';
import '../models/story_category.dart';
import '../services/hn_service.dart';
import '../state/saved_stories_controller.dart';
import '../state/settings_controller.dart';
import '../utils/story_actions.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/story_card.dart';
import 'about_page.dart';
import 'comments_screen.dart';
import 'story_detail_screen.dart';

/// Main feed screen: live Hacker News stories with category filters, search,
/// pull-to-refresh, and infinite scroll — matching the original app's logic.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.savedController,
    required this.settingsController,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final SavedStoriesController savedController;
  final SettingsController settingsController;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _service = HnService();
  static const _cache = FeedCacheStore();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  StoryCategory _selectedCategory = StoryCategory.all;
  FeedMode _mode = FeedMode.newest;
  String _query = '';

  final List<Story> _stories = [];
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingInitial = true;
      _hasError = false;
    });
    try {
      final stories = await _service.fetchStories(page: 0, mode: _mode);
      if (!mounted) return;
      setState(() {
        _stories
          ..clear()
          ..addAll(stories);
        _page = 1;
        _hasMore = stories.isNotEmpty;
        _isLoadingInitial = false;
        _isOffline = false;
      });
      unawaited(_cache.save(jsonEncode(stories.map((s) => s.toJson()).toList())));
    } catch (_) {
      if (!mounted) return;
      final cached = await _loadFromCache();
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
        _hasError = cached.isEmpty;
        _isOffline = cached.isNotEmpty;
        if (cached.isNotEmpty) {
          _stories
            ..clear()
            ..addAll(cached);
          _hasMore = false;
        }
      });
    }
  }

  Future<List<Story>> _loadFromCache() async {
    final raw = await _cache.load();
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>().map(Story.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isLoadingInitial || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final stories = await _service.fetchStories(page: _page, mode: _mode);
      if (!mounted) return;
      setState(() {
        _stories.addAll(stories);
        _page += 1;
        _hasMore = stories.isNotEmpty;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _setMode(FeedMode mode) {
    if (mode == _mode) return;
    setState(() => _mode = mode);
    _loadInitial();
  }

  List<Story> get _filteredStories {
    var stories = _stories
        .where((s) => _selectedCategory.matches(s.title))
        .toList();
    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      stories = stories
          .where((s) => s.title.toLowerCase().contains(query))
          .toList();
    }
    return stories;
  }

  void _openAbout() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AboutPage()));
  }

  void _openComments(Story story) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CommentsScreen(story: story)),
    );
  }

  void _openStory(Story story) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryDetailScreen(
          story: story,
          savedController: widget.savedController,
          settingsController: widget.settingsController,
        ),
      ),
    );
  }

  void _toggleTheme() {
    final isDark = widget.themeMode == ThemeMode.dark ||
        (widget.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    widget.onThemeModeChanged(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    final stories = _filteredStories;
    final isDark = widget.themeMode == ThemeMode.dark ||
        (widget.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tech and Feeds',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: _toggleTheme,
          ),
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _openAbout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitial,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search headlines…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SegmentedButton<FeedMode>(
                  segments: const [
                    ButtonSegment(
                      value: FeedMode.newest,
                      label: Text('Newest'),
                      icon: Icon(Icons.new_releases_outlined),
                    ),
                    ButtonSegment(
                      value: FeedMode.top,
                      label: Text('Top'),
                      icon: Icon(Icons.local_fire_department_outlined),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) => _setMode(selection.first),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: CategoryFilterBar(
                selectedCategory: _selectedCategory,
                onSelected: (category) =>
                    setState(() => _selectedCategory = category),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            if (_isOffline)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Couldn't reach the feed — showing your last saved headlines",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_isLoadingInitial)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasError && stories.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Couldn't reach the feed",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadInitial,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (stories.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No headlines match this filter yet.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: stories.length + (_isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= stories.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final story = stories[index];
                    return AnimatedBuilder(
                      animation: widget.savedController,
                      builder: (context, _) => StoryCard(
                        story: story,
                        isSaved: widget.savedController.isSaved(story),
                        onTap: () => _openStory(story),
                        onToggleSave: () =>
                            widget.savedController.toggle(story),
                        onShare: () => shareStory(story),
                        onOpenComments: () => _openComments(story),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

