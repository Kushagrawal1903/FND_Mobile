import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/network/api_client.dart';
import 'package:truthlens/features/auth/data/models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await _apiClient.post('/api/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return response.data['data'] ?? response.data;
  }

  Future<void> logout() async {
    await _apiClient.post('/api/auth/logout');
  }

  Future<User> getMe() async {
    final response = await _apiClient.get('/api/auth/me');
    final userData = response.data['data']['user'] ?? response.data['data'];
    return User.fromJson(userData);
  }
}
