import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/network/api_client.dart';

final verifyRemoteDataSourceProvider = Provider<VerifyRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VerifyRemoteDataSource(apiClient);
});

class VerifyRemoteDataSource {
  final ApiClient _apiClient;

  VerifyRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> checkClaim(String claim) async {
    final response = await _apiClient.post('/api/news/check', data: {'claim': claim});
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> analyzeClaim(String claim) async {
    final response = await _apiClient.post('/api/news/analyze', data: {'claim': claim});
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> checkUrl(String url) async {
    final response = await _apiClient.post('/api/news/url-check', data: {'url': url});
    return response.data['data'] ?? response.data;
  }
}
