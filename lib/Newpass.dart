import 'package:flutter/material.dart';

class NewPasswordScreen extends StatelessWidget {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reset your password',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                hintText: 'New password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: const BorderSide(),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _repeatPasswordController,
              decoration: InputDecoration(
                hintText: 'Repeat password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: const BorderSide(),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ฟังก์ชันที่ต้องการทำเมื่อกดปุ่ม Reset password
                  print(
                      'Passwords: ${_newPasswordController.text}, ${_repeatPasswordController.text}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Text(
                  'Reset password',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
