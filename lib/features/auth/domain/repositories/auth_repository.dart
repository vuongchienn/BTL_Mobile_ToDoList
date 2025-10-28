import '../entities/user.dart';

abstract class AuthRepository {
  /// Log in and persist token
  Future<Map<String, dynamic>> login(String email, String password);

  /// Get current user profile from backend
  Future<User> getProfile();

  /// Logout and clear token
  Future<void> logout();
  Future<Map<String, dynamic>> register(String email, String password,String passwordConfirmation);
}