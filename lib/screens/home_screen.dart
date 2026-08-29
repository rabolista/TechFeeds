import 'package:flutter/material.dart';

import '../models/story.dart';
import '../models/story_category.dart';
import '../services/hn_service.dart';
import '../state/saved_stories_controller.dart';
import '../state/settings_controller.dart';
import '../utils/story_actions.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/story_card.dart';
import 'about_page.dart';

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

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  StoryCategory _selectedCategory = StoryCategory.all;
  String _query = '';

  final List<Story> _stories = [];
  int _page = 0;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasError = false;

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
      final stories = await _service.fetchStories(page: 0);
      if (!mounted) return;
      setState(() {
        _stories
          ..clear()
          ..addAll(stories);
        _page = 1;
        _isLoadingInitial = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isLoadingInitial) return;
    setState(() => _isLoadingMore = true);
    try {
      final stories = await _service.fetchStories(page: _page);
      if (!mounted) return;
      setState(() {
        _stories.addAll(stories);
        _page += 1;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
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
              child: CategoryFilterBar(
                selectedCategory: _selectedCategory,
                onSelected: (category) =>
                    setState(() => _selectedCategory = category),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
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
                        onTap: () => openStoryLink(
                          story,
                          openInApp: widget.settingsController.openInApp,
                        ),
                        onToggleSave: () =>
                            widget.savedController.toggle(story),
                        onShare: () => shareStory(story),
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
