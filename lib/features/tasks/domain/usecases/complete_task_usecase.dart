// domain/usecases/complete_task_usecase.dart
import '../repositories/task_repository.dart';

class CompleteTaskUseCase {
  final TaskRepository repository;

  CompleteTaskUseCase(this.repository);

  Future<bool> call(int taskId) async {
    return repository.completeTask(taskId);
  }
}