import '../entities/user.dart';

abstract class AuthRepository {
  /// Log in and persist token
  Future<Map<String, dynamic>> login(String email, String password);

  /// Get current user profile from backend
  Future<User> getProfile();

  /// Logout and clear token
  Future<void> logout();
  Future<Map<String, dynamic>> register(String email, String password,String passwordConfirmation);
   Future<Map<String, dynamic>> sendOtp(String email);

  /// Xác thực OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp);

  /// Đặt lại mật khẩu
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
}