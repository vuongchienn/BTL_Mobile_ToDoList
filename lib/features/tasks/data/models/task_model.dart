class TaskModel {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isRepeating;
  final String time;
  final bool isImportant;
  final bool isAdminCreated;
  final List<String> tags;
  final int priority; 
  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.time,
    required this.isRepeating,
    required this.isImportant,
    required this.isAdminCreated,
    required this.priority,
    required this.tags,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      time: json['time'] ?? '',
      isRepeating: json['isRepeating'] ?? false,
      isImportant: json['isImportant'] ?? false,
      isAdminCreated: json['isAdminCreated'] ?? false,
      priority: json['priority'] ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}