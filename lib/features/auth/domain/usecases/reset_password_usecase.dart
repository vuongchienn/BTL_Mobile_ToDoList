import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;
  ResetPasswordUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _repository.resetPassword(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}