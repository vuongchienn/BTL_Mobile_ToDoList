import 'package:btl_mobile_todolist/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:btl_mobile_todolist/features/auth/domain/usecases/login_user.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_remote_data_source.dart'; // 👈 import lớp bạn đã có

import 'package:go_router/go_router.dart';
import '../../../../core/utils/auth_storage.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPasswordField = false;
  bool hasText = false;
  bool isLoading = false;
  bool obscurePassword = true;

  late final LoginUseCase loginUseCase;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onEmailChanged);

    // ⚙️ Khởi tạo Dio và AuthRemoteDataSource
    final dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api', // ⚠️ đổi URL theo Laravel backend của bạn
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
     final remoteDataSource = AuthRemoteDataSource(dio);
    final repository = AuthRepositoryImpl(remoteDataSource);
    loginUseCase = LoginUseCase(repository);

  }

  void _onEmailChanged() {
    if (!mounted) return;
    setState(() {
      hasText = emailController.text.isNotEmpty;
      if (emailController.text.isEmpty) showPasswordField = false;
    });
  }

  void _handleContinue() {
    if (hasText) {
      setState(() => showPasswordField = true);
    }
  }

  Future<void> _handleLogin() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin.')),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    // Gọi usecase (đảm bảo usecase trả về token hoặc user data)
    final result = await loginUseCase(email, password);
    // 🔐 Nếu loginUseCase trả về token:
    if (result['data'] != null) {
      await AuthStorage.saveToken(result['data']); // lưu token
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công ✅')),
      );
      // ✅ Điều hướng sang trang Home
      context.go(AppRoutes.home);
    } else {
      throw Exception('Không nhận được token từ server.');
    }
  } catch (e) {
    print("❌ Login error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đăng nhập thất bại: $e')),
    );
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4EF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Chào mừng trở lại!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Điền thông tin của bạn",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Ô nhập Email
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                       border: Border.all(color: Colors.grey.shade200, width: 1), // viền xám
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // màu bóng
                          blurRadius: 6, // độ mờ bóng
                          offset: const Offset(0, 3), // vị trí bóng
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: InputBorder.none,
                         contentPadding: EdgeInsets.only(right: 10),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Nếu showPasswordField = true => hiển thị ô nhập mật khẩu
                if (showPasswordField == true) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                       border: Border.all(color: Colors.grey.shade200, width: 1), // viền xám
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: const TextStyle(letterSpacing: 4),
                      decoration: InputDecoration(
                        labelText: "Mật khẩu",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Quên mật khẩu?",
                          style: TextStyle(color: Color(0xFFEF6820))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEF6820),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Đăng nhập"),
                  ),
                ] else ...[
                  // Nút tiếp tục
                  ElevatedButton(
                     onPressed: (hasText && !isLoading) ? _handleContinue : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor:
                          hasText ? Color(0xFFEF6820) : Colors.grey.shade500,
                      foregroundColor:
                          hasText ? Colors.white : Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Tiếp tục"),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 32, thickness: 1),
                  _socialButton(Icons.g_mobiledata, "Tiếp tục với Google"),
                  const SizedBox(height: 12),
                  _socialButton(Icons.facebook, "Tiếp tục với Facebook",
                      iconColor: Colors.blue),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Bạn chưa có tài khoản? "),
                      TextButton(onPressed: () => context.go(AppRoutes.register)
                      ,child: const Text(
                          "Đăng ký",
                          style: TextStyle(
                            color: Color(0xFFEF6820),
                            fontWeight: FontWeight.bold,
                          ),
                        ),)
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _socialButton(IconData icon, String text, {Color? iconColor}) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 28, color: iconColor ?? Colors.black),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }
}