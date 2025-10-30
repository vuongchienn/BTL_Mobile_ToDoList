import '../entities/note.dart';
import '../repositories/note_repository.dart';

class UpdateNoteUseCase {
  final NoteRepository repository;
  UpdateNoteUseCase(this.repository);

  Future<Note> call(int id, String content) async {
    return await repository.updateNote(id, content);
  }
}