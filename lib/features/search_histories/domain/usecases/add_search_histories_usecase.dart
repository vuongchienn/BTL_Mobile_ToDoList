import '../repositories/search_history_repository.dart';

class AddSearchHistoryUseCase {
  final SearchHistoryRepository repository;
  AddSearchHistoryUseCase(this.repository);

  Future<void> call(String query) async {
    await repository.addSearchHistory(query);
  }
}