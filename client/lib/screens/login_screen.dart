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

      print('[✅] 로그인 시도: $email');
      if (response.session != null) {
        print('[🎉] 로그인 성공: ${response.session!.user.id}');
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
        print('[❌] 로그인 실패: 세션 없음');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 실패: 세션을 가져오지 못했습니다')),
        );
      }
    } on AuthException catch (e) {
      print('[❌] AuthException: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 오류: ${e.message}')),
      );
    } catch (e) {
      print('[⚠️] 기타 오류: $e');
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
      appBar: AppBar(title: const Text('Login')),
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








// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'master_screen.dart';
// import 'user_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController idController = TextEditingController();
//   final TextEditingController pwController = TextEditingController();

// Future<void> login() async {
//   try {
//     final response = await Supabase.instance.client.auth.signInWithPassword(
//       email: idController.text.trim(),
//       password: pwController.text.trim(),
//     );

//     if (!mounted) return;

//     if (response.session != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => UserScreen(role: 'user')),
//       );
//     }
//   } on AuthException catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('로그인 오류: ${e.message}')),
//     );
//   } catch (e) {
//   print("[⚠️] 예외 발생: $e");
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text('기타 오류: $e')),
//   );
// }
//   print('Trying to login with email: ${idController.text}, password: ${pwController.text}');
// final response = await Supabase.instance.client.auth.signInWithPassword(
//   email: idController.text.trim(),
//   password: pwController.text.trim(),
// );
// print('Response: ${response.session}');
// print("[❌] 로그인 실패: ${e.message}");


// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: idController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: pwController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'Password'),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: login,
//               child: const Text('LOGIN'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






























// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'master_screen.dart';
// import 'user_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController idController = TextEditingController();
//   final TextEditingController pwController = TextEditingController();

//   Future<void> login() async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://127.0.0.1:8080/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'id': idController.text.trim(),
//           'password': pwController.text.trim(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);
//         if (!mounted) return;
//         if (result['role'] == 'admin') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => MasterScreen(role: 'admin')),
//           );
//         } else {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => UserScreen(role: 'user')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('로그인 실패: 아이디 또는 비밀번호를 확인하세요')),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('오류 발생: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: idController,
//               decoration: const InputDecoration(labelText: 'ID'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: pwController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'PASSWORD'),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: login,
//               child: const Text('LOGIN'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
