import 'package:flutter/material.dart';
import 'screens/bottombar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Hikyaku',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: BottomBar(key: BottomBar.globalKey), // globalKeyを渡す
    );
  }
}
