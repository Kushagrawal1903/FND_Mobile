import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/network/api_client.dart';

final feedbackRemoteDataSourceProvider = Provider<FeedbackRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedbackRemoteDataSource(apiClient);
});

class FeedbackRemoteDataSource {
  final ApiClient _apiClient;

  FeedbackRemoteDataSource(this._apiClient);

  Future<List<dynamic>> getUserFeedback() async {
    final response = await _apiClient.get('/api/reports');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> submitFeedback(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/reports', data: data);
    return response.data['data'] ?? response.data;
  }
}
