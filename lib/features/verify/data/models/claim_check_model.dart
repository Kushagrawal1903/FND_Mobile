class ClaimSource {
  final String id;
  final String publisher;
  final String url;
  final String verdict;

  ClaimSource({
    required this.id,
    required this.publisher,
    required this.url,
    required this.verdict,
  });

  factory ClaimSource.fromJson(Map<String, dynamic> json) {
    return ClaimSource(
      id: json['_id'] ?? '',
      publisher: json['publisher'] ?? '',
      url: json['url'] ?? '',
      verdict: json['verdict'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'publisher': publisher,
    'url': url,
    'verdict': verdict,
  };
}

class VerificationResult {
  final String id;
  final String claim;
  final String verdict;
  final int confidence;
  final String explanation;
  final List<ClaimSource> sources;
  final String? url;
  final String? extractedTitle;
  final List<String>? keywords;
  final int? wordCount;
  final DateTime createdAt;

  VerificationResult({
    required this.id,
    required this.claim,
    required this.verdict,
    required this.confidence,
    required this.explanation,
    required this.sources,
    this.url,
    this.extractedTitle,
    this.keywords,
    this.wordCount,
    required this.createdAt,
  });

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    // Determine the base node, the API wraps differently for url-check vs analyze vs check
    final Map<String, dynamic> vData = json['verification'] ?? json;
    
    return VerificationResult(
      id: vData['_id'] ?? '',
      claim: vData['claim'] ?? '',
      verdict: vData['verdict'] ?? 'unverified',
      confidence: vData['confidence'] ?? 0,
      explanation: vData['explanation'] ?? '',
      sources: (vData['sources'] as List<dynamic>?)
              ?.map((e) => ClaimSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      url: json['url'],
      extractedTitle: json['extractedTitle'],
      keywords: (json['analysis']?['keywords'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      wordCount: json['analysis']?['wordCount'],
      createdAt: DateTime.tryParse(vData['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
