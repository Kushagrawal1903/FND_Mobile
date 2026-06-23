import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/storage/local_cache_service.dart';
import 'package:truthlens/features/history/data/models/saved_article_model.dart';
import 'package:truthlens/features/history/data/history_remote_data_source.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final remoteDataSource = ref.watch(historyRemoteDataSourceProvider);
  final localCache = ref.watch(localCacheProvider);
  return HistoryRepository(remoteDataSource, localCache);
});

class HistoryRepository {
  final HistoryRemoteDataSource _remoteDataSource;
  final LocalCacheService _localCache;

  HistoryRepository(this._remoteDataSource, this._localCache);

  Future<List<SavedArticle>> getSavedArticles() async {
    try {
      final dataList = await _remoteDataSource.getSavedArticles();
      final articles = dataList.map((e) => SavedArticle.fromJson(e)).toList();
      
      // Update Cache
      final jsonList = articles.map((a) => a.toJson()).toList();
      await _localCache.saveData('bookmarksBox', 'all', jsonEncode(jsonList));
      return articles;
    } catch (e) {
      // Return cached if network fails
      final cachedStr = _localCache.getData('bookmarksBox', 'all');
      if (cachedStr != null) {
        final List<dynamic> decoded = jsonDecode(cachedStr);
        return decoded.map((e) => SavedArticle.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  Future<SavedArticle> saveArticle(SavedArticle article) async {
    final data = await _remoteDataSource.saveArticle({
      'title': article.title,
      'url': article.url,
      'verdict': article.verdict,
      'notes': article.notes,
    });
    return SavedArticle.fromJson(data);
  }

  Future<void> deleteArticle(String id) async {
    await _remoteDataSource.deleteArticle(id);
  }

  Future<SavedArticle> updateNotes(String id, String notes) async {
    final data = await _remoteDataSource.updateNotes(id, notes);
    return SavedArticle.fromJson(data);
  }
}
