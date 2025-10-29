import '../entities/task_group.dart';
import '../repositories/task_group_repository.dart';

class CreateTaskGroupUseCase {
  final TaskGroupRepository repository;
  CreateTaskGroupUseCase(this.repository);

  Future<TaskGroup> call(String name) async {
    return await repository.createTaskGroup(name);
  }
}