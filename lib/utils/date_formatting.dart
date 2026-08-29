/// Formats a UTC timestamp as a short relative time string (e.g. "5m ago",
/// "3h ago", "2d ago"), similar to the `amTimeAgo` directive used before.
String timeAgo(DateTime utcTime) {
  final now = DateTime.now().toUtc();
  final diff = now.difference(utcTime);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}
