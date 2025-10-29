import '../repositories/task_group_repository.dart';

class DeleteTaskGroupUseCase {
  final TaskGroupRepository repository;
  DeleteTaskGroupUseCase(this.repository);

  Future<void> call(int id) async {
    await repository.deleteTaskGroup(id);
  }
}