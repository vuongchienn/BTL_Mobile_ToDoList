import '../entities/task_group.dart';
import '../repositories/task_group_repository.dart';

class GetTaskGroupsUseCase {
  final TaskGroupRepository repository;
  GetTaskGroupsUseCase(this.repository);

  Future<List<TaskGroup>> call() async {
    return await repository.getTaskGroups();
  }
}