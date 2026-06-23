import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/features/auth/data/models/user_model.dart';
import 'package:truthlens/features/feedback/data/models/feedback_report_model.dart';
import 'package:truthlens/features/admin/data/admin_remote_data_source.dart';
import 'package:truthlens/features/admin/data/models/admin_analytics_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final remoteDataSource = ref.watch(adminRemoteDataSourceProvider);
  return AdminRepository(remoteDataSource);
});

class AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepository(this._remoteDataSource);

  Future<AdminAnalytics> getAnalytics() async {
    final data = await _remoteDataSource.getAnalytics();
    return AdminAnalytics.fromJson(data);
  }

  Future<List<User>> getUsers() async {
    final data = await _remoteDataSource.getUsers();
    return data.map((e) => User.fromJson(e)).toList();
  }

  Future<void> deleteUser(String id) async {
    await _remoteDataSource.deleteUser(id);
  }

  Future<List<FeedbackReport>> getReports() async {
    final data = await _remoteDataSource.getReports();
    return data.map((e) => FeedbackReport.fromJson(e)).toList();
  }

  Future<FeedbackReport> updateReportStatus(String id, String status) async {
    final data = await _remoteDataSource.updateReportStatus(id, status);
    return FeedbackReport.fromJson(data);
  }

  Future<void> deleteReport(String id) async {
    await _remoteDataSource.deleteReport(id);
  }
}
