import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<Map<String, List<TaskEntity>>> call(String type) {
    return repository.getTasksByType(type);
  }
  Future<Map<String, List<TaskEntity>>> getCompletedTasks() {
    return repository.getCompletedTasks();
  }

  Future<Map<String, List<TaskEntity>>> getDeletedTasks() {
    return repository.getDeletedTasks();
  }
    Future<bool> updateTask({
    required int taskDetailId,
    required String title,
    required String description,
    required String dueDate,
    required String time,
    required List<int> tagIds,
    required int priority, 
  }) {
    return repository.updateTask(
      taskDetailId: taskDetailId,
      title: title,
      description: description,
      dueDate: dueDate,
      time: time,
      tagIds: tagIds,
      priority: priority
    );
  }
}