class AdminAnalytics {
  final int totalUsers;
  final int totalFactChecks;
  final int pendingFeedback;
  final int savedBookmarks;
  final Map<String, int> verdictDistribution;

  AdminAnalytics({
    required this.totalUsers,
    required this.totalFactChecks,
    required this.pendingFeedback,
    required this.savedBookmarks,
    required this.verdictDistribution,
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    return AdminAnalytics(
      totalUsers: json['totalUsers'] ?? 0,
      totalFactChecks: json['totalFactChecks'] ?? 0,
      pendingFeedback: json['pendingFeedback'] ?? 0,
      savedBookmarks: json['savedBookmarks'] ?? 0,
      verdictDistribution: Map<String, int>.from(json['verdictDistribution'] ?? {}),
    );
  }
}
