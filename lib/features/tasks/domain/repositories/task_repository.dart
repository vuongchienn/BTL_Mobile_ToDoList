import '../entities/task.dart';
abstract class TaskRepository {
  Future<Map<String, List<TaskEntity>>> getTasksByType(String type);
}