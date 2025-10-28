import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:btl_mobile_todolist/core/routing/app_routes.dart';
import 'package:btl_mobile_todolist/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:btl_mobile_todolist/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:btl_mobile_todolist/features/auth/data/repositories/auth_repository_impl.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;

  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;
  int _timerSeconds = 119; // 01:59
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'));
    final VerifyOtpUseCase _verifyOtpUseCase = VerifyOtpUseCase(AuthRepositoryImpl(AuthRemoteDataSource(dio)));
    if (isLoading || _otpController.text.length != 6) return;
    setState(() => isLoading = true);

    try {
      final result = await _verifyOtpUseCase(widget.email, _otpController.text.trim());
      if (result['message'] == 'Xác thực OTP thành công.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực OTP thành công.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(
          AppRoutes.resetPassword,
          extra: {
            'email': widget.email,
            'otp': _otpController.text.trim(),
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xác thực OTP thất bại: ${result['message']}'),
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

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
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
                  "Nhập mã OTP",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Mã OTP đã được gửi đến email: ${widget.email}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.grey[200],
                    selectedFillColor: Colors.grey[300],
                  ),
                  controller: _otpController,
                  onChanged: (value) {},
                  onCompleted: (value) => _verifyOtp(),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatTime(_timerSeconds),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
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
                    onPressed: isLoading ? null : _verifyOtp,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Xác thực"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}