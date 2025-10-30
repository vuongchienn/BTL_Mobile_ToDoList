import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_remote_data_source.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Note>> getNotes(int paginate) async {
    return await remoteDataSource.getNotes(paginate);
  }

  @override
  Future<Note> createNote(String content) async {
    return await remoteDataSource.createNote(content);
  }

  @override
  Future<Note> updateNote(int id, String content) async {
    return await remoteDataSource.updateNote(id, content);
  }

  @override
  Future<void> deleteNote(int id) async {
    await remoteDataSource.deleteNote(id);
  }
}