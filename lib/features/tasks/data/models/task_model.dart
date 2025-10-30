class TaskModel {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isRepeating;
  final bool isImportant;
  final bool isAdminCreated;
  final List<String> tags;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isRepeating,
    required this.isImportant,
    required this.isAdminCreated,
    required this.tags,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      isRepeating: json['isRepeating'] ?? false,
      isImportant: json['isImportant'] ?? false,
      isAdminCreated: json['isAdminCreated'] ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}