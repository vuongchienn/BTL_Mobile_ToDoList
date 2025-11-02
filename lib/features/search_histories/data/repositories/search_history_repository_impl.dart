import '../../domain/entities/search_history.dart';
import '../../domain/repositories/search_history_repository.dart';
import '../datasources/search_history_remote_data_source.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final SearchHistoryRemoteDataSource remoteDataSource;

  SearchHistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SearchHistory>> getSearchHistories() async {
    try {
      final models = await remoteDataSource.getSearchHistories();
      return models.map((m) => SearchHistory(id: m.id, searchQuery: m.searchQuery)).toList();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

   @override
  Future<void> deleteSearchHistory(int id) async {
    await remoteDataSource.deleteSearchHistory(id);
  }
  @override
  Future<void> deleteAllSearchHistory() async {
    await remoteDataSource.deleteAllSearchHistory();
  }
  @override
  Future<void> addSearchHistory(String query) {
    return remoteDataSource.addSearchHistory(query);
  }


}