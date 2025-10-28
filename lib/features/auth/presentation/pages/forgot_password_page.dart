import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';
import 'package:btl_mobile_todolist/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:btl_mobile_todolist/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:btl_mobile_todolist/features/auth/data/repositories/auth_repository_impl.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  
  final emailController = TextEditingController();
  bool isLoading = false;
  

  Future<void> _sendOtp() async {
  
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'));
  final _sendOtpUseCase = SendOtpUseCase(AuthRepositoryImpl(AuthRemoteDataSource(dio)));
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final result = await _sendOtpUseCase(emailController.text.trim());
      if (result['message'] == 'OTP đã được gửi qua email.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP đã được gửi qua email.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRoutes.verifyOtp, extra: emailController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi OTP thất bại: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
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
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Xác thực email",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF6820),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isLoading ? null : _sendOtp,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Tiếp tục"),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Đăng ký / "),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: const Text(
                        "Đăng nhập",
                        style: TextStyle(
                          color: Color(0xFFEF6820),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey[100],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}