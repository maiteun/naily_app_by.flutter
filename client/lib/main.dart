
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/user_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vprspqajqjxcgdswawhh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZwcnNwcWFqcWp4Y2dkc3dhd2hoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NDczNDYsImV4cCI6MjA2NzQyMzM0Nn0.TO5qtptiYhr_DezGXap9IKi50M7U_nrGs_YL1fNg4gk',
    authFlowType: AuthFlowType.pkce,
  );

  final session = Supabase.instance.client.auth.currentSession;
  print("초기 세션: $session");

  runApp(MyApp(session: session));
}

class MyApp extends StatelessWidget {
  final Session? session;
  const MyApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: session != null
          ? UserScreen(role: 'user')
          : const LoginScreen(),
    );
  }
}
