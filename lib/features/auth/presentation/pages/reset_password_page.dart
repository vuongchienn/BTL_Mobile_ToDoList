import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';
import 'package:btl_mobile_todolist/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:btl_mobile_todolist/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:btl_mobile_todolist/features/auth/data/repositories/auth_repository_impl.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordPage({super.key, required this.email,required this.otp,});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  bool hasLetter = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  void _validatePassword(String value) {
    setState(() {
      hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
      hasNumber = RegExp(r'[0-9]').hasMatch(value);
      hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(value);
      hasMinLength = value.length >= 8;
    });
  }

  Future<void> _resetPassword() async {
    if (isLoading || passwordController.text != confirmController.text) return;
    setState(() => isLoading = true);

    try {
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'));
      final resetPasswordUseCase = ResetPasswordUseCase(AuthRepositoryImpl(AuthRemoteDataSource(dio)));
      final result = await resetPasswordUseCase(
        email: widget.email,
        otp: widget.otp,
        password: passwordController.text.trim(),
        passwordConfirmation: confirmController.text.trim(),
      );
      if (result['message'] == 'Đặt lại mật khẩu thành công.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRoutes.resetPasswordSuccess); // Quay lại trang đăng nhập
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt lại mật khẩu thất bại: ${result['message']}'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Đặt lại mật khẩu",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Nhập lại mật khẩu",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: passwordController,
                  label: 'Mật khẩu',
                  icon: Icons.lock_outline,
                  obscureText: obscurePassword,
                  onChanged: _validatePassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildPasswordRequirements(),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: confirmController,
                  label: 'Nhập lại mật khẩu',
                  icon: Icons.lock_outline,
                  obscureText: obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => obscureConfirm = !obscureConfirm);
                    },
                  ),
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
                    onPressed: isLoading || passwordController.text != confirmController.text || !hasMinLength || !hasLetter || !hasNumber || !hasSpecial ? null : _resetPassword,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Đặt lại mật khẩu"),
                  ),
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
    bool obscureText = false,
    void Function(String)? onChanged,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    int strengthCount = [
      hasLetter,
      hasNumber,
      hasSpecial,
      hasMinLength,
    ].where((e) => e).length;

    Widget checkRow(bool ok, String text) {
      return Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.circle_outlined,
              color: ok ? Colors.green : Colors.grey, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: ok ? Colors.green : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                height: 5,
                decoration: BoxDecoration(
                  color: index < strengthCount ? Colors.green : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        checkRow(hasLetter, "Chữ (a → z)"),
        checkRow(hasNumber, "Số (0 → 9)"),
        checkRow(hasSpecial, "Ký tự đặc biệt (!, @, #, %, …)"),
        checkRow(hasMinLength, "Độ dài tối thiểu 8 ký tự trở lên"),
      ],
    );
  }
}