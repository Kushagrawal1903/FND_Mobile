import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/network/api_client.dart';

final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HistoryRemoteDataSource(apiClient);
});

class HistoryRemoteDataSource {
  final ApiClient _apiClient;

  HistoryRemoteDataSource(this._apiClient);

  Future<List<dynamic>> getSavedArticles() async {
    final response = await _apiClient.get('/api/users/saved-articles');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> saveArticle(Map<String, dynamic> articleData) async {
    final response = await _apiClient.post('/api/users/saved-articles', data: articleData);
    return response.data['data'] ?? response.data;
  }

  Future<void> deleteArticle(String id) async {
    await _apiClient.delete('/api/users/saved-articles/$id');
  }

  // If there's an update endpoint, else typically we delete & save again or put
  Future<Map<String, dynamic>> updateNotes(String id, String notes) async {
    // Assuming a PUT or PATCH exists, if not we'll just mock or use the save endpoint
    final response = await _apiClient.put('/api/users/saved-articles/$id', data: {'notes': notes});
    return response.data['data'] ?? response.data;
  }
}
