// lib/screens/tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'bottombar.dart'; // BottomBar画面への遷移用

class TutorialScreen extends StatelessWidget {
  final pages = [
    PageViewModel(
      pageColor: Colors.blue,
      bubble: Icon(Icons.touch_app, size: 30.0, color: Colors.white),
      title: Text("アプリの使い方", style: TextStyle(fontWeight: FontWeight.bold)),
      body: Text("簡単な操作方法を説明します。スワイプして次のページへ進んでください。"),
      mainImage: Icon(Icons.phone_android, size: 200.0, color: Colors.white),
    ),
    PageViewModel(
      pageColor: Colors.green,
      bubble: Icon(Icons.visibility, size: 30.0, color: Colors.white),
      title: Text("私たちのビジョン", style: TextStyle(fontWeight: FontWeight.bold)),
      body: Text("このアプリで、あなたの生活をもっと便利に。理念や目標を共有します。"),
      mainImage:
          Icon(Icons.lightbulb_outline, size: 200.0, color: Colors.white),
    ),
    // 必要に応じてページを追加してください
  ];

  @override
  Widget build(BuildContext context) {
    return IntroViewsFlutter(
      pages,
      onTapDoneButton: () {
        // チュートリアル完了後、BottomBarへ遷移
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomBar()),
        );
      },
      pageButtonTextStyles: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
    );
  }
}
