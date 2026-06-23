import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/features/history/data/history_repository.dart';
import 'package:truthlens/features/history/data/models/saved_article_model.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryNotifier(repository);
});

class HistoryState {
  final bool isLoading;
  final String? error;
  final List<SavedArticle> articles;

  HistoryState({
    this.isLoading = false,
    this.error,
    this.articles = const [],
  });

  HistoryState copyWith({
    bool? isLoading,
    String? error,
    List<SavedArticle>? articles,
    bool clearError = false,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      articles: articles ?? this.articles,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;

  HistoryNotifier(this._repository) : super(HistoryState()) {
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final articles = await _repository.getSavedArticles();
      state = state.copyWith(isLoading: false, articles: articles);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addArticle(SavedArticle article) async {
    try {
      final newArticle = await _repository.saveArticle(article);
      state = state.copyWith(articles: [newArticle, ...state.articles]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeArticle(String id) async {
    try {
      await _repository.deleteArticle(id);
      state = state.copyWith(
        articles: state.articles.where((a) => a.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateNotes(String id, String notes) async {
    try {
      final updatedArticle = await _repository.updateNotes(id, notes);
      state = state.copyWith(
        articles: state.articles.map((a) => a.id == id ? updatedArticle : a).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
