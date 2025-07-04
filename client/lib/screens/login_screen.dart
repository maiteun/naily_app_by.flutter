import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/master_screen.dart';
import '../screens/user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8080/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': idController.text.trim(),
          'password': pwController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (!mounted) return;
        if (result['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MasterScreen(role: 'admin')),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => UserScreen(role: 'user')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 실패: 아이디 또는 비밀번호를 확인하세요')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pwController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: login,
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
