import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/storage/local_cache_service.dart';
import 'package:truthlens/features/feedback/data/models/feedback_report_model.dart';
import 'package:truthlens/features/feedback/data/feedback_remote_data_source.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final remoteDataSource = ref.watch(feedbackRemoteDataSourceProvider);
  final localCache = ref.watch(localCacheProvider);
  return FeedbackRepository(remoteDataSource, localCache);
});

class FeedbackRepository {
  final FeedbackRemoteDataSource _remoteDataSource;
  final LocalCacheService _localCache;

  FeedbackRepository(this._remoteDataSource, this._localCache);

  Future<List<FeedbackReport>> getUserFeedback() async {
    try {
      final dataList = await _remoteDataSource.getUserFeedback();
      final reports = dataList.map((e) => FeedbackReport.fromJson(e)).toList();
      
      // Update Cache
      final jsonList = reports.map((a) => a.toJson()).toList();
      await _localCache.saveData('reportsBox', 'all', jsonEncode(jsonList));
      return reports;
    } catch (e) {
      // Fallback to cache
      final cachedStr = _localCache.getData('reportsBox', 'all');
      if (cachedStr != null) {
        final List<dynamic> decoded = jsonDecode(cachedStr);
        return decoded.map((e) => FeedbackReport.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  Future<FeedbackReport> submitFeedback(String title, String description) async {
    final data = await _remoteDataSource.submitFeedback({
      'title': title,
      'description': description,
    });
    return FeedbackReport.fromJson(data);
  }
}
