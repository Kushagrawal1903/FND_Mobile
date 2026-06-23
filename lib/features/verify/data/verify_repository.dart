import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/features/verify/data/models/claim_check_model.dart';
import 'package:truthlens/features/verify/data/verify_remote_data_source.dart';

final verifyRepositoryProvider = Provider<VerifyRepository>((ref) {
  final remoteDataSource = ref.watch(verifyRemoteDataSourceProvider);
  return VerifyRepository(remoteDataSource);
});

class VerifyRepository {
  final VerifyRemoteDataSource _remoteDataSource;

  VerifyRepository(this._remoteDataSource);

  Future<VerificationResult> checkClaim(String claim) async {
    final data = await _remoteDataSource.checkClaim(claim);
    return VerificationResult.fromJson(data);
  }

  Future<VerificationResult> analyzeClaim(String claim) async {
    final data = await _remoteDataSource.analyzeClaim(claim);
    return VerificationResult.fromJson(data);
  }

  Future<VerificationResult> checkUrl(String url) async {
    final data = await _remoteDataSource.checkUrl(url);
    return VerificationResult.fromJson(data);
  }
}
