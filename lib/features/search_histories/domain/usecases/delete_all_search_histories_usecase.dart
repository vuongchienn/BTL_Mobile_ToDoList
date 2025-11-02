import '../repositories/search_history_repository.dart';

class DeleteAllSearchHistoryUseCase {
  final SearchHistoryRepository _repository;

  DeleteAllSearchHistoryUseCase(this._repository);

  Future<void> call() async {
    await _repository.deleteAllSearchHistory();
  }
}