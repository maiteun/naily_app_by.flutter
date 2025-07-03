import 'package:flutter/material.dart';

class MasterScreen extends StatelessWidget {
  final String role;

  const MasterScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$role Home')),
      body: Center(
        child: Text(
          'Welcome, $role! 👑',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
