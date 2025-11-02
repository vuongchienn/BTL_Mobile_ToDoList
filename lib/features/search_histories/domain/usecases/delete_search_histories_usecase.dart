import '../repositories/search_history_repository.dart';

class DeleteSearchHistoryUseCase {
  final SearchHistoryRepository repository;
  DeleteSearchHistoryUseCase(this.repository);

  Future<void> call(int id) async {
    return repository.deleteSearchHistory(id);
  }
}