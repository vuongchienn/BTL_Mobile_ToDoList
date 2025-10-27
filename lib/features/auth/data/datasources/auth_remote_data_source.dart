import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSource(this.dio);

  /// POST /auth/login
  /// Laravel trả về: { status: true, message: 'Login successful', data: '<token>' }
 Future<void> login(String email, String password) async {
  try {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    print("Login response: ${response.data}");

    // Token Laravel trả nằm ở response.data['data']
    String? token;
    if (response.data is Map<String, dynamic>) {
      token = response.data['data']?.toString();
    }

    if (token == null || token.isEmpty) {
      throw Exception("Token null hoặc rỗng");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    print("Token lưu thành công: $token");
  } catch (e) {
    print("Login error: $e");
    throw Exception("Lỗi khi đăng nhập: $e");
  }
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