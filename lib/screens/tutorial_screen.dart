// lib/screens/tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'bottombar.dart'; // BottomBar画面への遷移用

/// アプリの使い方を説明するチュートリアル画面
class TutorialScreen extends StatelessWidget {
  /// チュートリアルのページビューモデルを作成
  final List<PageViewModel> pages = [
    PageViewModel(
      pageColor: Colors.blue,
      bubble: Icon(Icons.touch_app, size: 30.0, color: Colors.white),
      title: Text("アプリの使い方",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
      body: Text(
        "簡単な操作方法を説明します。スワイプして次のページへ進んでください。",
        style: TextStyle(fontSize: 16.0),
      ),
      mainImage: Icon(Icons.phone_android, size: 200.0, color: Colors.white),
    ),
    PageViewModel(
      pageColor: Colors.green,
      bubble: Icon(Icons.visibility, size: 30.0, color: Colors.white),
      title: Text("私たちのビジョン",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
      body: Text(
        "このアプリで、あなたの生活をもっと便利に。理念や目標を共有します。",
        style: TextStyle(fontSize: 16.0),
      ),
      mainImage:
          Icon(Icons.lightbulb_outline, size: 200.0, color: Colors.white),
    ),
    PageViewModel(
      pageColor: Colors.orange,
      bubble: Icon(Icons.star, size: 30.0, color: Colors.white),
      title: Text("さあ、始めましょう",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
      body: Text(
        "準備が整いました！アプリを使い始めるには「完了」をタップしてください。",
        style: TextStyle(fontSize: 16.0),
      ),
      mainImage:
          Icon(Icons.check_circle_outline, size: 200.0, color: Colors.white),
    ),
  ];

  /// チュートリアル画面のビルド
  @override
  Widget build(BuildContext context) {
    return IntroViewsFlutter(
      pages,
      onTapDoneButton: () => _navigateToHome(context),
      showSkipButton: true,
      skipText: Text("スキップ"),
      doneText: Text("完了"),
      pageButtonTextStyles: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// チュートリアル完了後、ホーム画面へ遷移する
  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomBar()),
    );
  }
}
