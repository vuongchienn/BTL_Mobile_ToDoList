import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;
  VerifyOtpUseCase(this._repository);

  Future<Map<String, dynamic>> call(String email, String otp) async {
    return await _repository.verifyOtp(email, otp);
  }
}