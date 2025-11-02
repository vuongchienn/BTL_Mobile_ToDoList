import 'package:dio/dio.dart';
import '../models/search_history_model.dart';

class SearchHistoryRemoteDataSource {
  final Dio dio;

  SearchHistoryRemoteDataSource(this.dio);

  Future<List<SearchHistoryModel>> getSearchHistories() async {
    try {
      final response = await dio.get('/search-history');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          return []; // Trả về danh sách rỗng nếu không có dữ liệu
        }
        if (data is! List) {
          throw Exception('Dữ liệu trả về không phải là danh sách: $data');
        }
        return (data as List).map((json) => SearchHistoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load search histories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching search histories: $e');
    }
  }

    Future<void> deleteSearchHistory(int id) async {
    await dio.delete('/search-history/$id');
  }

  Future<void> deleteAllSearchHistory() async {
  await dio.delete('/search-history');
}

Future<void> addSearchHistory(String query) async {
  final response = await dio.post(
    '/search-history', // endpoint bên Laravel
    data: {'search_query': query},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to add search history');
  }
}


}