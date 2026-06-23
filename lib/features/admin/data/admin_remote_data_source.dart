import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/network/api_client.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminRemoteDataSource(apiClient);
});

class AdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _apiClient.get('/api/admin/analytics');
    return response.data['data'] ?? response.data;
  }

  Future<List<dynamic>> getUsers() async {
    final response = await _apiClient.get('/api/admin/users');
    return response.data['data'] ?? [];
  }

  Future<void> deleteUser(String id) async {
    await _apiClient.delete('/api/admin/users/$id');
  }

  Future<List<dynamic>> getReports() async {
    final response = await _apiClient.get('/api/admin/reports');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> updateReportStatus(String id, String status) async {
    final response = await _apiClient.put('/api/admin/reports/$id', data: {'status': status});
    return response.data['data'] ?? response.data;
  }

  Future<void> deleteReport(String id) async {
    await _apiClient.delete('/api/admin/reports/$id');
  }
}
