class FeedbackReport {
  final String id;
  final String title;
  final String? type;
  final String? url;
  final String description;
  final String status;
  final DateTime createdAt;

  FeedbackReport({
    required this.id,
    required this.title,
    this.type,
    this.url,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory FeedbackReport.fromJson(Map<String, dynamic> json) {
    return FeedbackReport(
      id: json['_id'] ?? '',
      title: json['title'] ?? json['type'] ?? 'Feedback Report',
      type: json['type'],
      url: json['url'],
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'type': type,
      'url': url,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
