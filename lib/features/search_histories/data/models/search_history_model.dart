class SearchHistoryModel {
  final int id;
  final String searchQuery;

  SearchHistoryModel({
    required this.id,
    required this.searchQuery,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'],
      searchQuery: json['search_query'],
    );
  }
}