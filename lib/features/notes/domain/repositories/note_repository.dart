import '../entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes(int paginate);
  Future<Note> createNote(String content);
  Future<Note> updateNote(int id, String content);
  Future<void> deleteNote(int id);
}