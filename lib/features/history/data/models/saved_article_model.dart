class SavedArticle {
  final String id;
  final String title;
  final String url;
  final String verdict;
  final String notes;
  final DateTime savedAt;

  SavedArticle({
    required this.id,
    required this.title,
    required this.url,
    required this.verdict,
    required this.notes,
    required this.savedAt,
  });

  factory SavedArticle.fromJson(Map<String, dynamic> json) {
    return SavedArticle(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      verdict: json['verdict'] ?? 'unverified',
      notes: json['notes'] ?? '',
      savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'url': url,
      'verdict': verdict,
      'notes': notes,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  SavedArticle copyWith({
    String? id,
    String? title,
    String? url,
    String? verdict,
    String? notes,
    DateTime? savedAt,
  }) {
    return SavedArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      verdict: verdict ?? this.verdict,
      notes: notes ?? this.notes,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
