import 'package:flutter/material.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'package:dio/dio.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool agreePolicy = false;

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

  Future<void> _register() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'));
  final usecase = RegisterUseCase(
    AuthRepositoryImpl(AuthRemoteDataSource(dio)),
  );

  try {
    final result = await usecase(
      emailController.text.trim(),
      passwordController.text.trim(),
      confirmController.text.trim(), // ✅ thêm trường xác nhận
    );
    if (!mounted) return;

    if (result['data'] == 'Register successful' ||
        result['message'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thất bại: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi kết nối hoặc server: $e'),
        backgroundColor: Colors.red,
      ),
    );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Tạo tài khoản",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Điền thông tin của bạn",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Email
                _buildInputField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Password
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

                // Confirm password
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

                const SizedBox(height: 16),

                // Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: agreePolicy,
                      activeColor: const Color(0xFFEF6820),
                      onChanged: (value) {
                        setState(() => agreePolicy = value ?? false);
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'Đồng ý với ',
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Điều khoản Dịch vụ',
                              style: const TextStyle(
                                  color: Color(0xFFEF6820),
                                  fontWeight: FontWeight.w500),
                            ),
                            const TextSpan(text: ' và '),
                            TextSpan(
                              text: 'Chính sách Bảo mật',
                              style: const TextStyle(
                                  color: Color(0xFFEF6820),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          agreePolicy ? const Color(0xFFEF6820) : Colors.grey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: agreePolicy ? _register : null,
                    child: const Text("Đăng ký"),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: RichText(
                    text: const TextSpan(
                      text: "Bạn đã có tài khoản? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Đăng nhập",
                          style: TextStyle(
                            color: Color(0xFFEF6820),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
  // Đếm số điều kiện đã thỏa mãn
  int strengthCount = [
    hasLetter,
    hasNumber,
    hasSpecial,
    hasMinLength
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
      // 🔹 Thanh ngang hiển thị độ mạnh
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

      // 🔹 Các điều kiện chi tiết
      checkRow(hasLetter, "Chữ (a → z)"),
      checkRow(hasNumber, "Số (0 → 9)"),
      checkRow(hasSpecial, "Ký tự đặc biệt (!, @, #, %, …)"),
      checkRow(hasMinLength, "Độ dài tối thiểu 8 ký tự trở lên"),
    ],
  );
}

}