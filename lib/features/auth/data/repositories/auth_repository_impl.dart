import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
 Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await remote.login(email, password);
    return response;
  }

  @override
  Future<User> getProfile() async {
    final userModel = await remote.getProfile();
    return userModel.toEntity();
  }

  @override
  Future<void> logout() => remote.logout();

  @override
    Future<Map<String, dynamic>> register(
        String email, String password, String passwordConfirmation) {
      return remote.register(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    }

   Future<Map<String, dynamic>> sendOtp(String email) {
    return remote.sendOtp(email);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) {
    return remote.verifyOtp(email, otp);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) {
    return remote.resetPassword(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}