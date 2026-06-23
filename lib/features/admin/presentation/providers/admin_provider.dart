import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/features/auth/data/models/user_model.dart';
import 'package:truthlens/features/feedback/data/models/feedback_report_model.dart';
import 'package:truthlens/features/admin/data/admin_repository.dart';
import 'package:truthlens/features/admin/data/models/admin_analytics_model.dart';

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminNotifier(repository)..fetchDashboardData();
});

class AdminState {
  final bool isLoading;
  final String? error;
  final AdminAnalytics? analytics;
  final List<User> users;
  final List<FeedbackReport> reports;

  AdminState({
    this.isLoading = false,
    this.error,
    this.analytics,
    this.users = const [],
    this.reports = const [],
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    AdminAnalytics? analytics,
    List<User>? users,
    List<FeedbackReport>? reports,
    bool clearError = false,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      analytics: analytics ?? this.analytics,
      users: users ?? this.users,
      reports: reports ?? this.reports,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(AdminState());

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final analytics = await _repository.getAnalytics();
      final users = await _repository.getUsers();
      final reports = await _repository.getReports();
      
      state = state.copyWith(
        isLoading: false, 
        analytics: analytics,
        users: users,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _repository.deleteUser(id);
      state = state.copyWith(
        users: state.users.where((u) => u.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateReportStatus(String id, String status) async {
    try {
      final updatedReport = await _repository.updateReportStatus(id, status);
      state = state.copyWith(
        reports: state.reports.map((r) => r.id == id ? updatedReport : r).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _repository.deleteReport(id);
      state = state.copyWith(
        reports: state.reports.where((r) => r.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
