import '../entities/search_history.dart';

abstract class SearchHistoryRepository {
  Future<List<SearchHistory>> getSearchHistories();
   Future<void> deleteSearchHistory(int id);
   Future<void> deleteAllSearchHistory();
  Future<void> addSearchHistory(String query);
}