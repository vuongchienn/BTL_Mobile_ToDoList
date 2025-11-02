
import '../entities/search_history.dart';
import '../repositories/search_history_repository.dart';

class GetSearchHistoriesUseCase {
  final SearchHistoryRepository repository;

  GetSearchHistoriesUseCase(this.repository);

  Future<List<SearchHistory>> call() {
    return repository.getSearchHistories();
  }
}