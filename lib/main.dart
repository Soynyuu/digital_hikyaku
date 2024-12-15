import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'shared_preferences_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://bqabgflrgntwukbkwote.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxYWJnZmxyZ250d3VrYmt3b3RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE1MDY4MjIsImV4cCI6MjA0NzA4MjgyMn0.qbVjf0lOx3SOGkKqxg7GCiSzRnCAMXw84e_LwjlxbXM',
    authOptions: FlutterAuthClientOptions(
      localStorage: MySharedPreferencesStorage(),
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'digital-hikyaku',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Color(0xFFCAFFD3), // 背景色を設定
      ),
      home: AuthCheck(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/': (context) => HomeScreen(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return LoginScreen();
    } else {
      return HomeScreen();
    }
  }
}
