import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';

void main() {
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
      
      initialRoute: '/login',//最初に表示する画面を設定
      routes: {//ルートの割り振り
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/': (context) => HomeScreen(),
      },
    );
  }
}
