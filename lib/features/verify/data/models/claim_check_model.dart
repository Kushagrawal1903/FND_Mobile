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

class EvidenceCard {
  final String id;
  final String title;
  final String url;
  final String source;
  final String snippet;
  final String credibilityScore;
  final String evidenceType;
  final String verdict;

  EvidenceCard({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    required this.snippet,
    required this.credibilityScore,
    required this.evidenceType,
    required this.verdict,
  });

  factory EvidenceCard.fromJson(Map<String, dynamic> json) {
    return EvidenceCard(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      source: json['source'] ?? '',
      snippet: json['snippet'] ?? '',
      credibilityScore: (json['credibilityScore'] ?? '').toString(),
      evidenceType: json['evidenceType'] ?? '',
      verdict: json['verdict'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'source': source,
    'snippet': snippet,
    'credibilityScore': credibilityScore,
    'evidenceType': evidenceType,
    'verdict': verdict,
  };
}

class SourceCredibility {
  final String domain;
  final String url;
  final String trustScore;
  final String reliability;
  final String historicalConfidence;
  final bool officialSource;
  final String reason;

  SourceCredibility({
    required this.domain,
    required this.url,
    required this.trustScore,
    required this.reliability,
    required this.historicalConfidence,
    required this.officialSource,
    required this.reason,
  });

  factory SourceCredibility.fromJson(Map<String, dynamic> json) {
    return SourceCredibility(
      domain: json['domain'] ?? json['sourceName'] ?? json['publisher'] ?? json['url'] ?? '',
      url: json['url'] ?? '',
      trustScore: (json['trustScore'] ?? json['score'] ?? '').toString(),
      reliability: json['reliability'] ?? '',
      historicalConfidence: (json['historicalConfidence'] ?? '').toString(),
      officialSource: json['officialSource'] ?? false,
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'domain': domain,
    'url': url,
    'trustScore': trustScore,
    'reliability': reliability,
    'historicalConfidence': historicalConfidence,
    'officialSource': officialSource,
    'reason': reason,
  };
}

class PipelineStep {
  final String agent;
  final String label;
  final String status;
  final bool success;
  final double durationMs;
  final String startedAt;
  final String endedAt;
  final int retries;
  final List<String> errors;

  PipelineStep({
    required this.agent,
    required this.label,
    required this.status,
    required this.success,
    required this.durationMs,
    required this.startedAt,
    required this.endedAt,
    required this.retries,
    required this.errors,
  });

  factory PipelineStep.fromJson(Map<String, dynamic> json) {
    return PipelineStep(
      agent: json['agent'] ?? '',
      label: json['label'] ?? '',
      status: json['status'] ?? 'not_run',
      success: json['success'] ?? false,
      durationMs: (json['durationMs'] ?? 0.0).toDouble(),
      startedAt: json['startedAt'] ?? '',
      endedAt: json['endedAt'] ?? '',
      retries: json['retries'] ?? 0,
      errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'agent': agent,
    'label': label,
    'status': status,
    'success': success,
    'durationMs': durationMs,
    'startedAt': startedAt,
    'endedAt': endedAt,
    'retries': retries,
    'errors': errors,
  };
}

class PerformanceMetrics {
  final double totalMs;
  final double factCheckMs;
  final double newsSearchMs;
  final double webSearchMs;
  final double credibilityMs;
  final double llmAnalysisMs;
  final Map<String, double> agents;
  final Map<String, double> tools;

  PerformanceMetrics({
    required this.totalMs,
    required this.factCheckMs,
    required this.newsSearchMs,
    required this.webSearchMs,
    required this.credibilityMs,
    required this.llmAnalysisMs,
    required this.agents,
    required this.tools,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    final agentsMap = <String, double>{};
    if (json['agents'] is Map) {
      (json['agents'] as Map).forEach((k, v) {
        agentsMap[k.toString()] = (v ?? 0.0).toDouble();
      });
    }

    final toolsMap = <String, double>{};
    if (json['tools'] is Map) {
      (json['tools'] as Map).forEach((k, v) {
        toolsMap[k.toString()] = (v ?? 0.0).toDouble();
      });
    }

    return PerformanceMetrics(
      totalMs: (json['totalMs'] ?? 0.0).toDouble(),
      factCheckMs: (json['factCheckMs'] ?? 0.0).toDouble(),
      newsSearchMs: (json['newsSearchMs'] ?? 0.0).toDouble(),
      webSearchMs: (json['webSearchMs'] ?? 0.0).toDouble(),
      credibilityMs: (json['credibilityMs'] ?? 0.0).toDouble(),
      llmAnalysisMs: (json['llmAnalysisMs'] ?? 0.0).toDouble(),
      agents: agentsMap,
      tools: toolsMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalMs': totalMs,
    'factCheckMs': factCheckMs,
    'newsSearchMs': newsSearchMs,
    'webSearchMs': webSearchMs,
    'credibilityMs': credibilityMs,
    'llmAnalysisMs': llmAnalysisMs,
    'agents': agents,
    'tools': tools,
  };
}

class VerificationMetadata {
  final int evidenceRound;
  final int sourceCount;
  final int searchCount;
  final int confidenceThreshold;
  final String timestamp;
  final List<String> visitedTools;
  final List<String> errors;

  VerificationMetadata({
    required this.evidenceRound,
    required this.sourceCount,
    required this.searchCount,
    required this.confidenceThreshold,
    required this.timestamp,
    required this.visitedTools,
    required this.errors,
  });

  factory VerificationMetadata.fromJson(Map<String, dynamic> json) {
    return VerificationMetadata(
      evidenceRound: json['evidenceRound'] ?? 0,
      sourceCount: json['sourceCount'] ?? 0,
      searchCount: json['searchCount'] ?? 0,
      confidenceThreshold: json['confidenceThreshold'] ?? 75,
      timestamp: json['timestamp'] ?? '',
      visitedTools: (json['visitedTools'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'evidenceRound': evidenceRound,
    'sourceCount': sourceCount,
    'searchCount': searchCount,
    'confidenceThreshold': confidenceThreshold,
    'timestamp': timestamp,
    'visitedTools': visitedTools,
    'errors': errors,
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

  // Agentic detailed fields
  final String rawVerdict;
  final String summary;
  final List<String> reasoning;
  final List<dynamic> supportingEvidence;
  final List<dynamic> conflictingEvidence;
  final List<EvidenceCard> evidenceCards;
  final List<SourceCredibility> credibility;
  final List<PipelineStep> pipeline;
  final PerformanceMetrics? performance;
  final VerificationMetadata? metadata;
  final Map<String, dynamic> raw;

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
    required this.rawVerdict,
    required this.summary,
    required this.reasoning,
    required this.supportingEvidence,
    required this.conflictingEvidence,
    required this.evidenceCards,
    required this.credibility,
    required this.pipeline,
    this.performance,
    this.metadata,
    required this.raw,
  });

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> body = json;
    final Map<String, dynamic> payload = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final Map<String, dynamic> vData = payload['verification'] is Map 
        ? payload['verification'] as Map<String, dynamic> 
        : payload;

    final String rawVer = vData['verdict']?.toString() ?? '';
    final String verdictNorm = _normalizeVerdict(rawVer);

    // Get workflow
    final Map<String, dynamic> agentDetails = payload['agentDetails'] is Map
        ? Map<String, dynamic>.from(payload['agentDetails'])
        : (vData['agentDetails'] is Map ? Map<String, dynamic>.from(vData['agentDetails']) : {});
    
    final Map<String, dynamic> workflow = Map<String, dynamic>.from(
      agentDetails['workflowState'] ??
      vData['workflowState'] ??
      payload['workflowState'] ??
      (payload['report'] is Map ? (payload['report'] as Map)['workflowState'] ?? {} : {})
    );

    // Get report
    final Map<String, dynamic> report = Map<String, dynamic>.from(
      workflow['report'] ??
      payload['report'] ??
      agentDetails['report'] ??
      payload['agentReport'] ?? {}
    );

    // Get executionMetadata
    final Map<String, dynamic> executionMetadata = Map<String, dynamic>.from(
      report['executionMetadata'] ??
      agentDetails['executionMetadata'] ??
      (workflow['report'] is Map ? (workflow['report'] as Map)['executionMetadata'] ?? {} : {})
    );

    // Get timings
    final Map<String, dynamic> performanceJson = Map<String, dynamic>.from(
      body['performance'] ??
      payload['performance'] ??
      vData['performance'] ??
      executionMetadata['timings'] ??
      workflow['timings'] ?? {}
    );

    final List<dynamic> credibilityListRaw = report['credibility'] ?? workflow['credibility'] ?? agentDetails['credibility'] ?? [];
    final List<dynamic> evidenceListRaw = report['evidence'] ?? workflow['evidence'] ?? agentDetails['evidence'] ?? [];

    // Helper functions executions
    final List<EvidenceCard> evidenceCards = _collectEvidenceCards(evidenceListRaw, credibilityListRaw);
    final List<ClaimSource> sources = _collectReferences(report, vData, evidenceCards);

    final List<dynamic> reasoningListRaw = report['reasoning'] ?? (workflow['reasoning'] is Map ? (workflow['reasoning'] as Map)['reasoning'] ?? [] : []) ?? agentDetails['reasoning'] ?? vData['reasoning'] ?? [];
    final List<String> reasoning = reasoningListRaw.map((e) => e.toString()).toList();
    if (reasoning.isEmpty && (vData['explanation'] != null || report['explanation'] != null)) {
      reasoning.add(vData['explanation'] ?? report['explanation'] ?? '');
    }

    final supportingEvidence = report['supportingEvidence'] ?? (workflow['reasoning'] is Map ? (workflow['reasoning'] as Map)['supportingEvidence'] ?? [] : []) ?? [];
    final conflictingEvidence = report['conflictingEvidence'] ?? (workflow['reasoning'] is Map ? (workflow['reasoning'] as Map)['conflictingEvidence'] ?? [] : []) ?? [];

    final List<SourceCredibility> parsedCredibility = credibilityListRaw
        .map((e) => SourceCredibility.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final List<PipelineStep> pipeline = _normalizePipeline(workflow, performanceJson);

    final PerformanceMetrics performance = PerformanceMetrics.fromJson(performanceJson);

    final String createdAtStr = vData['createdAt']?.toString() ?? workflow['endedAt']?.toString() ?? executionMetadata['timestamp']?.toString() ?? '';

    // Metadata
    final int evidenceRound = workflow['metadata']?['evidenceRound'] ?? executionMetadata['evidenceRound'] ?? 0;
    final int sourceCount = sources.length;
    final int searchCount = evidenceListRaw.where((item) => item is Map && RegExp(r'search|factcheck', caseSensitive: false).hasMatch((item['toolName'] ?? '').toString())).length;
    final int confidenceThreshold = workflow['metadata']?['confidenceThreshold'] ?? report['executionMetadata']?['confidenceThreshold'] ?? 75;
    final List<String> visitedTools = (workflow['visitedTools'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (executionMetadata['visitedTools'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final List<String> errors = (workflow['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (executionMetadata['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    final VerificationMetadata metadata = VerificationMetadata(
      evidenceRound: evidenceRound,
      sourceCount: sourceCount,
      searchCount: searchCount,
      confidenceThreshold: confidenceThreshold,
      timestamp: createdAtStr,
      visitedTools: visitedTools,
      errors: errors,
    );

    return VerificationResult(
      id: vData['_id']?.toString() ?? payload['_id']?.toString() ?? '',
      claim: vData['claim'] ?? workflow['extractedClaim'] ?? executionMetadata['extractedClaim'] ?? payload['extractedTitle'] ?? payload['url'] ?? 'Not Available',
      verdict: verdictNorm,
      confidence: vData['confidence'] ?? report['confidence'] ?? workflow['confidence'] ?? 0,
      explanation: report['explanation'] ?? (workflow['reasoning'] is Map ? (workflow['reasoning'] as Map)['explanation'] ?? '' : '') ?? vData['explanation'] ?? report['summary'] ?? 'Not Available',
      sources: sources,
      url: payload['url'],
      extractedTitle: payload['extractedTitle'],
      keywords: (payload['analysis']?['keywords'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      wordCount: payload['analysis']?['wordCount'],
      createdAt: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
      rawVerdict: rawVer,
      summary: report['summary'] ?? vData['explanation'] ?? 'Not Available',
      reasoning: reasoning,
      supportingEvidence: supportingEvidence is List ? supportingEvidence : [],
      conflictingEvidence: conflictingEvidence is List ? conflictingEvidence : [],
      evidenceCards: evidenceCards,
      credibility: parsedCredibility,
      pipeline: pipeline,
      performance: performance,
      metadata: metadata,
      raw: body,
    );
  }

  static String _normalizeVerdict(String value) {
    final verdict = value.toLowerCase().trim();
    if (['true', 'real', 'likely true'].contains(verdict)) return 'true';
    if (['false', 'fake', 'likely false'].contains(verdict)) return 'false';
    if (['mixed', 'mixture', 'misleading'].contains(verdict)) return 'mixture';
    return 'unverified';
  }

  static List<EvidenceCard> _collectEvidenceCards(List<dynamic> evidence, List<dynamic> credibility) {
    final credibilityByUrl = <String, Map<String, dynamic>>{};
    for (var item in credibility) {
      if (item is Map && item['url'] != null) {
        credibilityByUrl[item['url'].toString()] = Map<String, dynamic>.from(item);
      }
    }

    final cards = <EvidenceCard>[];

    for (int evidenceIndex = 0; evidenceIndex < evidence.length; evidenceIndex++) {
      final item = evidence[evidenceIndex];
      if (item is! Map) continue;
      final result = item['result'] is Map ? item['result'] as Map : {};
      final evidenceType = item['toolName'] ?? result['provider'] ?? 'Evidence';

      // Claims/reviews
      final claims = result['claims'] is List ? result['claims'] as List : [];
      for (int claimIndex = 0; claimIndex < claims.length; claimIndex++) {
        final claim = claims[claimIndex];
        if (claim is! Map) continue;
        final reviews = claim['reviews'] is List ? claim['reviews'] as List : [];
        for (int reviewIndex = 0; reviewIndex < reviews.length; reviewIndex++) {
          final review = reviews[reviewIndex];
          if (review is! Map) continue;
          final url = review['url']?.toString() ?? '';
          final sourceCredibility = credibilityByUrl[url];
          final trustScore = sourceCredibility?['trustScore'] ?? sourceCredibility?['score'] ?? 'Not Available';
          cards.add(EvidenceCard(
            id: '$evidenceIndex-claim-$claimIndex-$reviewIndex',
            title: review['title']?.toString() ?? claim['text']?.toString() ?? 'Fact-check review',
            url: url,
            source: review['publisher']?.toString() ?? claim['claimant']?.toString() ?? _getHost(url),
            snippet: claim['text']?.toString() ?? review['rating']?.toString() ?? 'Not Available',
            credibilityScore: trustScore.toString(),
            evidenceType: evidenceType.toString(),
            verdict: review['rating']?.toString() ?? review['verdict']?.toString() ?? 'Not Available',
          ));
        }
      }

      // Credibility sources
      final credibilitySources = (result['credibility'] is Map && result['credibility']['sources'] is List)
          ? result['credibility']['sources'] as List
          : [];
      for (int sourceIndex = 0; sourceIndex < credibilitySources.length; sourceIndex++) {
        final source = credibilitySources[sourceIndex];
        if (source is! Map) continue;
        final url = source['url']?.toString() ?? '';
        final sourceCredibility = credibilityByUrl[url];
        final trustScore = sourceCredibility?['trustScore'] ?? sourceCredibility?['score'] ?? 'Not Available';
        cards.add(EvidenceCard(
          id: '$evidenceIndex-source-$sourceIndex',
          title: source['publisher']?.toString() ?? _getHost(url),
          url: url,
          source: source['publisher']?.toString() ?? _getHost(url),
          snippet: source['verdict']?.toString() ?? 'Not Available',
          credibilityScore: trustScore.toString(),
          evidenceType: evidenceType.toString(),
          verdict: source['verdict']?.toString() ?? 'Not Available',
        ));
      }

      // Results
      final searchResults = result['results'] is List ? result['results'] as List : [];
      for (int resultIndex = 0; resultIndex < searchResults.length; resultIndex++) {
        final searchResult = searchResults[resultIndex];
        if (searchResult is! Map) continue;
        final url = searchResult['url']?.toString() ?? '';
        final sourceCredibility = credibilityByUrl[url];
        final trustScore = sourceCredibility?['trustScore'] ?? sourceCredibility?['score'] ?? 'Not Available';
        cards.add(EvidenceCard(
          id: '$evidenceIndex-result-$resultIndex',
          title: searchResult['title']?.toString() ?? _getHost(url),
          url: url,
          source: searchResult['publisher']?.toString() ?? _getHost(url),
          snippet: searchResult['snippet']?.toString() ?? searchResult['content']?.toString() ?? 'Not Available',
          credibilityScore: trustScore.toString(),
          evidenceType: evidenceType.toString(),
          verdict: searchResult['verdict']?.toString() ?? 'Not Available',
        ));
      }
    }

    final seen = <String>{};
    final uniqueCards = <EvidenceCard>[];
    for (var card in cards) {
      final key = '${card.url}|${card.title}|${card.source}';
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueCards.add(card);
      }
    }
    return uniqueCards;
  }

  static List<ClaimSource> _collectReferences(Map<String, dynamic> report, Map<String, dynamic> verification, List<EvidenceCard> evidenceCards) {
    final refs = <Map<String, dynamic>>[];

    final reportRefs = report['references'] is List ? report['references'] as List : [];
    for (var r in reportRefs) {
      if (r is Map) refs.add(Map<String, dynamic>.from(r));
    }

    final verificationSources = verification['sources'] is List ? verification['sources'] as List : [];
    for (var s in verificationSources) {
      if (s is Map) refs.add(Map<String, dynamic>.from(s));
    }

    for (var card in evidenceCards) {
      refs.add({
        'publisher': card.source,
        'url': card.url,
        'verdict': card.verdict,
      });
    }

    final seen = <String>{};
    final uniqueRefs = <ClaimSource>[];
    for (var ref in refs) {
      final url = ref['url']?.toString() ?? '';
      final publisher = ref['publisher'] ?? ref['name'] ?? _getHost(url);
      final verdict = ref['verdict'] ?? ref['rating'] ?? 'Not Available';
      final key = '$publisher|$url';
      if (url.isNotEmpty || publisher.toString().isNotEmpty) {
        if (!seen.contains(key)) {
          seen.add(key);
          uniqueRefs.add(ClaimSource(
            id: ref['_id']?.toString() ?? '',
            publisher: publisher.toString(),
            url: url,
            verdict: verdict.toString(),
          ));
        }
      }
    }
    return uniqueRefs;
  }

  static List<PipelineStep> _normalizePipeline(Map<String, dynamic> workflow, Map<String, dynamic> timings) {
    final history = workflow['executionHistory'] is List ? workflow['executionHistory'] as List : [];
    final agentsFromHistory = history.where((entry) => entry is Map && entry['type'] == 'agent').toList();
    final latestByAgent = <String, Map>{};
    for (var entry in agentsFromHistory) {
      if (entry is Map && entry['agent'] != null) {
        latestByAgent[entry['agent'].toString()] = entry;
      }
    }

    final agentTimings = timings['agents'] is Map 
        ? timings['agents'] as Map 
        : (workflow['timings'] is Map && workflow['timings']['agents'] is Map)
            ? workflow['timings']['agents'] as Map
            : {};

    const pipelineOrder = ['planner', 'content', 'evidence', 'credibility', 'reasoning', 'verification', 'report'];

    return pipelineOrder.map((agent) {
      final entry = latestByAgent[agent];
      final durationMs = entry != null 
          ? (entry['durationMs'] ?? 0.0).toDouble() 
          : (agentTimings[agent] ?? 0.0).toDouble();

      final errorsList = entry != null && entry['errors'] is List ? entry['errors'] as List : [];
      final hasErrors = errorsList.isNotEmpty;
      final executed = entry != null || durationMs > 0;

      String status = 'not_run';
      if (executed) {
        status = hasErrors ? 'failed' : 'success';
      }

      return PipelineStep(
        agent: agent,
        label: agent.substring(0, 1).toUpperCase() + agent.substring(1),
        status: status,
        success: executed && !hasErrors,
        durationMs: durationMs,
        startedAt: entry?['startedAt']?.toString() ?? 'Not Available',
        endedAt: entry?['endedAt']?.toString() ?? 'Not Available',
        retries: entry?['retries'] ?? 0,
        errors: errorsList.map((e) => e.toString()).toList(),
      );
    }).toList();
  }

  static String _getHost(String url) {
    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (_) {
      return 'Not Available';
    }
  }
}
