import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class GetProfileUseCase {
  final AuthRepository _repository;
  GetProfileUseCase(this._repository);

  Future<User> call() {
    return _repository.getProfile();
  }
}