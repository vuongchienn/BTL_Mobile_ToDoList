import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<Map<String, dynamic>> call(
    String email,
    String password,
    String passwordConfirmation,
  ) {
    return _repository.register(email, password, passwordConfirmation);
  }
}