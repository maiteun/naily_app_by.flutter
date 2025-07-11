import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'master_screen.dart';
import 'user_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });
    try {
      final email = emailController.text.trim();
      final password = pwController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일과 비밀번호를 모두 입력하세요')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print(' 로그인 시도: $email');
      if (response.session != null) {
        print('로그인 성공: ${response.session!.user.id}');
        if (!mounted) return;

        if (email == 'master@gmail.com' && password == '123456') {
          // 관리자 계정
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MasterScreen(role: 'admin'),
            ),
          );
        } else {
          // 일반 유저
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const UserScreen(role: 'user'),
            ),
          );
        }
      } else {
        print('로그인 실패: 세션 없음');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 실패: 세션을 가져오지 못했습니다')),
        );
      }
    } on AuthException catch (e) {
      print('AuthException: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 오류: ${e.message}')),
      );
    } catch (e) {
      print('기타 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기타 오류: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NAILY LOGIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pwController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 32),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}

