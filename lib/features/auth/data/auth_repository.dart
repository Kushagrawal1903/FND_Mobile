import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/storage/secure_storage_service.dart';
import 'package:truthlens/core/storage/local_cache_service.dart';
import 'package:truthlens/features/auth/data/auth_remote_data_source.dart';
import 'package:truthlens/features/auth/data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final localCache = ref.watch(localCacheProvider);
  return AuthRepository(remoteDataSource, secureStorage, localCache);
});

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final LocalCacheService _localCache;

  AuthRepository(this._remoteDataSource, this._secureStorage, this._localCache);

  Future<User> login(String email, String password) async {
    final data = await _remoteDataSource.login(email, password);
    final token = data['token'];
    final userJson = data['user'];
    
    await _secureStorage.saveToken(token);
    await _secureStorage.saveUser(jsonEncode(userJson));
    return User.fromJson(userJson);
  }

  Future<User> register(String name, String email, String password) async {
    final data = await _remoteDataSource.register(name, email, password);
    final token = data['token'];
    final userJson = data['user'];

    await _secureStorage.saveToken(token);
    await _secureStorage.saveUser(jsonEncode(userJson));
    return User.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await _secureStorage.clearAll();
      await _localCache.clearAll();
    }
  }

  Future<User?> getCachedUser() async {
    final userJson = await _secureStorage.getUser();
    if (userJson != null && userJson.isNotEmpty) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<User> getMe() async {
    final user = await _remoteDataSource.getMe();
    await _secureStorage.saveUser(jsonEncode(user.toJson()));
    return user;
  }
}
