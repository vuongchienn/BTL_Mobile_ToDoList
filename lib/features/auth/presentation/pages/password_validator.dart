import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PasswordValidator extends StatefulWidget {
  const PasswordValidator({super.key});

  @override
  State<PasswordValidator> createState() => _PasswordValidatorState();
}

class _PasswordValidatorState extends State<PasswordValidator> {
  String password = '';

  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecial => password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  bool get hasMinLength => password.length >= 8;

  Color getColor(bool condition) => condition ? Colors.green : Colors.grey;

  int get strengthCount {
    int count = 0;
    if (hasUppercase) count++;
    if (hasNumber) count++;
    if (hasSpecial) count++;
    if (hasMinLength) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (val) => setState(() => password = val),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nhập mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // 4 thanh ngang hiển thị độ mạnh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index < strengthCount
                          ? Colors.green
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            buildCondition("Chữ hoa (A → Z)", hasUppercase),
            buildCondition("Số (0 → 9)", hasNumber),
            buildCondition("Ký tự đặc biệt (!, @, #, ...)", hasSpecial),
            buildCondition("Tối thiểu 8 ký tự", hasMinLength),
          ],
        ),
      ),
    );
  }

  Widget buildCondition(String text, bool condition) {
    return Row(
      children: [
        Icon(
          FontAwesomeIcons.checkCircle,
          color: getColor(condition),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: getColor(condition)),
        ),
      ],
    );
  }
}