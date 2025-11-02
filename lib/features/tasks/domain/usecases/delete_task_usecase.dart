// delete_task_usecase.dart
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<bool> call(int taskId) async {
    return repository.deleteTask(taskId);
  }
  Future<bool> deleteBin(int taskDetailId) async {
    return await repository.deleteBin(taskDetailId); // Gọi API deleteBin
  }

  Future<bool> deleteAllBinTasks() async {
    return await repository.deleteAllBinTasks();
  }
}