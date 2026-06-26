class AdminAnalytics {
  final int totalUsers;
  final int totalFactChecks;
  final int pendingFeedback;
  final int savedBookmarks;
  final Map<String, int> verdictDistribution;
  final int averageConfidence;

  AdminAnalytics({
    required this.totalUsers,
    required this.totalFactChecks,
    required this.pendingFeedback,
    required this.savedBookmarks,
    required this.verdictDistribution,
    required this.averageConfidence,
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    // React backend returns: { stats: { totals: { users, factChecks, savedArticles }, verdicts: { true, false, mixture, unverified }, reports: { pending }, averageConfidence } }
    final Map<String, dynamic> stats = json['stats'] ?? json;
    final Map<String, dynamic> totals = stats['totals'] ?? {};
    final Map<String, dynamic> verdicts = stats['verdicts'] ?? {};
    final Map<String, dynamic> reports = stats['reports'] ?? {};

    return AdminAnalytics(
      totalUsers: totals['users'] ?? stats['totalUsers'] ?? 0,
      totalFactChecks: totals['factChecks'] ?? stats['totalFactChecks'] ?? 0,
      pendingFeedback: reports['pending'] ?? stats['pendingFeedback'] ?? 0,
      savedBookmarks: totals['savedArticles'] ?? stats['savedBookmarks'] ?? 0,
      verdictDistribution: {
        'true': verdicts['true'] ?? 0,
        'false': verdicts['false'] ?? 0,
        'mixture': verdicts['mixture'] ?? 0,
        'unverified': verdicts['unverified'] ?? 0,
      },
      averageConfidence: stats['averageConfidence'] ?? 0,
    );
  }
}
