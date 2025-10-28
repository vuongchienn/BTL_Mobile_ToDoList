import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSource(this.dio);

  /// POST /auth/login
  /// Laravel trả về: { status: true, message: 'Login successful', data: '<token>' }
 Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      return response.data; // nên chứa {'token': '...'}
    } else {
      throw Exception('Đăng nhập thất bại: ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return response.data;
  }
  /// Lấy profile user (nếu bạn chưa có API /auth/user thì tạm bỏ hoặc test sau)
 Future<UserModel> getProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) throw Exception('Chưa có token');

  dio.options.headers['Authorization'] = 'Bearer $token';

  final response = await dio.get('/auth/user');
  if (response.statusCode == 200) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return UserModel.fromJson(data['data']);
    }
    return UserModel.fromJson(data);
  } else {
    throw Exception('Không lấy được thông tin người dùng');
  }
}

  /// POST /auth/logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      await dio.post('/auth/logout');
    } catch (e) {
      print('⚠️ Lỗi khi logout (có thể token đã hết hạn)');
    }

    // Xoá token khỏi local
    await prefs.remove('token');
    dio.options.headers.remove('Authorization');
    print('👋 Đã đăng xuất');
  }
}