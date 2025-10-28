import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository _repository;
  SendOtpUseCase(this._repository);

  Future<Map<String, dynamic>> call(String email) async {
    return await _repository.sendOtp(email);
  }
}