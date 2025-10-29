import '../entities/task_group.dart';
import '../repositories/task_group_repository.dart';

class UpdateTaskGroupUseCase {
  final TaskGroupRepository repository;
  UpdateTaskGroupUseCase(this.repository);

  Future<TaskGroup> call(int id, String name) async {
    return await repository.updateTaskGroup(id, name);
  }
}