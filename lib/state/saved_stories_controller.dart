import 'package:flutter/foundation.dart';

import '../data/saved_stories_store.dart';
import '../models/story.dart';

/// Shared, observable list of bookmarked stories so the Feed, Saved, and
/// Settings tabs all stay in sync.
class SavedStoriesController extends ChangeNotifier {
  SavedStoriesController({this._store = const SavedStoriesStore()});

  final SavedStoriesStore _store;
  List<Story> _saved = [];

  List<Story> get saved => List.unmodifiable(_saved);
  Set<String> get savedIds => _saved.map((s) => s.id).toSet();

  Future<void> load() async {
    _saved = await _store.load();
    notifyListeners();
  }

  bool isSaved(Story story) => _saved.any((s) => s.id == story.id);

  Future<void> toggle(Story story) async {
    if (isSaved(story)) {
      _saved = _saved.where((s) => s.id != story.id).toList();
    } else {
      _saved = [..._saved, story];
    }
    notifyListeners();
    await _store.save(_saved);
  }

  Future<void> clear() async {
    _saved = [];
    notifyListeners();
    await _store.save(_saved);
  }
}
