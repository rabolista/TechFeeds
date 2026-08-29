import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/story.dart';
import '../services/hn_service.dart';
import '../utils/date_formatting.dart';

/// Native, in-app viewer for a story's Hacker News discussion — real
/// structured-data processing, not just a browser wrapper.
class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, required this.story});

  final Story story;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  static const _service = HnService();

  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final comments = await _service.fetchComments(widget.story.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  List<Widget> _flatten(List<Comment> comments, int depth) {
    final widgets = <Widget>[];
    for (final comment in comments) {
      widgets.add(_CommentTile(comment: comment, depth: depth));
      widgets.addAll(_flatten(comment.children, depth + 1));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discussion')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      const Center(child: Text("Couldn't load comments")),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _load,
                          child: const Text('Try again'),
                        ),
                      ),
                    ],
                  )
                : _comments.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('No comments yet.')),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Text(
                              widget.story.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Divider(height: 24),
                          ..._flatten(_comments, 0),
                        ],
                      ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.depth});

  final Comment comment;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16 + depth * 16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.author,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text('•', style: theme.textTheme.labelMedium),
              const SizedBox(width: 6),
              Text(timeAgo(comment.createdAtUtc), style: theme.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
