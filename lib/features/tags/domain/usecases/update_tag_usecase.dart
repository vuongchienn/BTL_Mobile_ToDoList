
import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

class UpdateTagUseCase {
  final TagRepository repository;
  UpdateTagUseCase(this.repository);

  Future<Tag> call(int id, String name) async {
    return await repository.updateTag(id, name);
  }
}