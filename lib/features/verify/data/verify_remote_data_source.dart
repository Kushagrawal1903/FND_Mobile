import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/network/api_client.dart';

final verifyRemoteDataSourceProvider = Provider<VerifyRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VerifyRemoteDataSource(apiClient);
});

class VerifyRemoteDataSource {
  final ApiClient _apiClient;

  VerifyRemoteDataSource(this._apiClient);

  /// Returns the FULL response body (status, data, performance) so that
  /// VerificationResult.fromJson can parse both agentDetails and performance.
  Future<Map<String, dynamic>> checkClaim(String claim) async {
    final response = await _apiClient.post('/api/news/check', data: {'claim': claim});
    final body = response.data;
    if (body is Map<String, dynamic>) return body;
    return {'data': body};
  }

  Future<Map<String, dynamic>> analyzeClaim(String newsText) async {
    final response = await _apiClient.post('/api/v1/news-analysis/analyze', data: {'newsText': newsText});
    final body = response.data;
    if (body is Map<String, dynamic>) return body;
    return {'data': body};
  }

  Future<Map<String, dynamic>> checkUrl(String url) async {
    final response = await _apiClient.post('/api/news/url-check', data: {'url': url});
    final body = response.data;
    if (body is Map<String, dynamic>) return body;
    return {'data': body};
  }

  Future<Map<String, dynamic>> getFactCheck(String id) async {
    final response = await _apiClient.get('/api/news/check/$id');
    final body = response.data;
    if (body is Map<String, dynamic>) return body;
    return {'data': body};
  }
}
