import '../../domain/entities/task_group.dart' as domain;

class TaskGroupModel {
  final int id;
  final String name;
  final int isAdminCreated;
  final int userId;

  TaskGroupModel({
    required this.id,
    required this.name,
    required this.isAdminCreated,
    required this.userId,
  });

  factory TaskGroupModel.fromJson(Map<String, dynamic> json) {
    return TaskGroupModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      isAdminCreated: json['is_admin_created'] is int
          ? json['is_admin_created']
          : int.parse((json['is_admin_created'] ?? 0).toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse((json['user_id'] ?? 0).toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_admin_created': isAdminCreated,
      'user_id': userId,
    };
  }

  /// Chuyển sang domain entity
  domain.TaskGroup toEntity() {
    return domain.TaskGroup(
      id: id,
      name: name,
      isAdminCreated: isAdminCreated,
      userId: userId,
    );
  }
}