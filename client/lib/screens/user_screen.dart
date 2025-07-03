import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  final String role;

  const UserScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$role Home')),
      body: Center(
        child: Text(
          'Welcome, $role! 🌸',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
