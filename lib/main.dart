import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/login.dart';

void main() {
  // デバッグモードでHTTPSの証明書エラーを無視
  if (kDebugMode) {
    WidgetsFlutterBinding.ensureInitialized();
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'digital_hikyaku',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const LoginScreen(),
    );
  }
}
