class TaskEntity {
  final int id;
  final int taskId;
  final String title;
  final String? description;
  final String dueDate;
  final String time;
  final int priority;
  final bool isRepeating;
  final bool isImportant;
  final bool isAdminCreated;
  final List<String> tags;

  TaskEntity({
    required this.id,
    required this.taskId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.time,
    required this.isRepeating,
    required this.isImportant,
    required this.isAdminCreated,
    required this.priority,
    required this.tags,
  });

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: (json['id'] as int?) ?? 0, // Gán 0 nếu null
      taskId: (json['task_id'] as int?) ?? 0, // Gán 0 nếu null
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] as String,
      time: json['time'] ?? '',
      priority: json['priority'] ?? 0,
      isRepeating: _parseBool(json['isRepeating']),
      isImportant: _parseBool(json['isImportant']),
      isAdminCreated: _parseBool(json['isAdminCreated']),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1; // Chuyển 1 thành true, 0 thành false
    if (value is String) return value.toLowerCase() == 'true'; // Xử lý nếu là string
    return false; // Giá trị mặc định nếu không parse được
  }
}