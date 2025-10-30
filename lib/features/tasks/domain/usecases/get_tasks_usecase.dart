import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<Map<String, List<TaskEntity>>> call(String type) {
    return repository.getTasksByType(type);
  }
}