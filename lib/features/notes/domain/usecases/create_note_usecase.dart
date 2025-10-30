import '../entities/note.dart';
import '../repositories/note_repository.dart';

class CreateNoteUseCase {
  final NoteRepository repository;
  CreateNoteUseCase(this.repository);

  Future<Note> call(String content) async {
    return await repository.createNote(content);
  }
}