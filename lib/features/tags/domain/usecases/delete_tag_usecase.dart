import '../repositories/tag_repository.dart';

class DeleteTagUseCase {
  final TagRepository repository;
  DeleteTagUseCase(this.repository);

  Future<void> call(int id) async {
    await repository.deleteTag(id);
  }
}