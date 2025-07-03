// login_screen.dart 파일 내용 전체가 이와 같아야 합니다.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    print('[_login] 함수 시작');
    final url = Uri.parse('http://localhost:8080/login');
    print('[_login] 요청 URL: $url');
    print('[_login] 입력된 ID: ${_usernameController.text}, 입력된 PW: ${_passwordController.text}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      print('[_login] 서버 응답 상태 코드: ${response.statusCode}');
      print('[_login] 서버 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        print('[_login] 로그인 성공 조건 충족');
        // 로그인 성공 시 AlertDialog 표시
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('로그인 성공'),
              content: const Text('성공적으로 로그인되었습니다.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // AlertDialog 닫기
                    // TODO: 로그인 성공 후 다음 화면으로 이동하는 로직 추가 (예시)
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => HomeScreen()));
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        print('[_login] 로그인 실패 조건 충족, 상태 코드: ${response.statusCode}');
        // 로그인 실패 시 AlertDialog 표시
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('로그인 실패'),
              content: Text('로그인에 실패했습니다. (상태 코드: ${response.statusCode}, 본문: ${response.body})'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('[_login] 네트워크 요청 중 예외 발생: $e');
      // 네트워크 오류 시 AlertDialog 표시
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('오류 발생'),
            content: Text('네트워크 오류가 발생했습니다: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _login,
                child: const Text('LOGIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}