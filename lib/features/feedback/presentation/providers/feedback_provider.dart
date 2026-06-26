import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/features/feedback/data/feedback_repository.dart';
import 'package:truthlens/features/feedback/data/models/feedback_report_model.dart';

final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return FeedbackNotifier(repository)..fetchReports();
});

class FeedbackState {
  final bool isLoading;
  final String? error;
  final List<FeedbackReport> reports;

  FeedbackState({
    this.isLoading = false,
    this.error,
    this.reports = const [],
  });

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    List<FeedbackReport>? reports,
    bool clearError = false,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      reports: reports ?? this.reports,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  final FeedbackRepository _repository;

  FeedbackNotifier(this._repository) : super(FeedbackState());

  Future<void> fetchReports() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final reports = await _repository.getUserFeedback();
      state = state.copyWith(isLoading: false, reports: reports);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitReport(String title, String description) async {
    try {
      final newReport = await _repository.submitFeedback(title, description);
      state = state.copyWith(reports: [newReport, ...state.reports]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
