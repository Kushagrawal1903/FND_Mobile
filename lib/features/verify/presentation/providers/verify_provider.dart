import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/features/verify/data/models/claim_check_model.dart';
import 'package:truthlens/features/verify/data/verify_repository.dart';

final verifyProvider = StateNotifierProvider<VerifyNotifier, VerifyState>((ref) {
  final repository = ref.watch(verifyRepositoryProvider);
  return VerifyNotifier(repository);
});

class VerifyState {
  final bool isLoading;
  final String? error;
  final VerificationResult? result;

  VerifyState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  VerifyState copyWith({
    bool? isLoading,
    String? error,
    VerificationResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return VerifyState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

class VerifyNotifier extends StateNotifier<VerifyState> {
  final VerifyRepository _repository;

  VerifyNotifier(this._repository) : super(VerifyState());

  void clearResult() {
    state = state.copyWith(clearResult: true, clearError: true);
  }

  Future<void> checkClaim(String claim) async {
    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);
    try {
      final result = await _repository.checkClaim(claim);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkUrl(String url) async {
    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);
    try {
      final result = await _repository.checkUrl(url);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deepAnalyze(String newsText) async {
    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);
    try {
      final result = await _repository.analyzeClaim(newsText);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reportProvider = FutureProvider.family<VerificationResult, String>((ref, id) async {
  final repository = ref.watch(verifyRepositoryProvider);
  return repository.getFactCheck(id);
});
