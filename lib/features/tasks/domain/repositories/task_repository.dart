import '../entities/task.dart';
abstract class TaskRepository {
  Future<Map<String, List<TaskEntity>>> getTasksByType(String type);
  Future<Map<String, List<TaskEntity>>> getCompletedTasks(); // Thêm phương thức này
  Future<Map<String, List<TaskEntity>>> getDeletedTasks(); //
  Future<TaskEntity?> createTask({
    required String title,
    required String description,
    required int groupId,
    required DateTime dueDate,
    required String time, // <--- đổi từ TimeOfDay sang String
    required int dueDateSelect,
    required int repeatType,
    int? repeatOption,
    int? repeatInterval,
    DateTime? repeatDueDate,
    List<int>? tagIds,
  });
    Future<bool> updateTask({
    required int taskDetailId,
    required String title,
    required String description,
    required String dueDate,
    required String time,
    required List<int> tagIds,
    required int priority, 
  });

  Future<bool> deleteTask(int taskId);
  Future<bool> completeTask(int taskId);
}