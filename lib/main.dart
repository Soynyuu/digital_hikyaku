import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://bqabgflrgntwukbkwote.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxYWJnZmxyZ250d3VrYmt3b3RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE1MDY4MjIsImV4cCI6MjA0NzA4MjgyMn0.qbVjf0lOx3SOGkKqxg7GCiSzRnCAMXw84e_LwjlxbXM',
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

      initialRoute: '/login', //最初に表示する画面を設定
      routes: {
        //ルートの割り振り
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/': (context) => HomeScreen(),
      },
    );
  }
}
