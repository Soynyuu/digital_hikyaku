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
      bubble: Icon(Icons.mail_outline, size: 30.0, color: Colors.white),
      title: Text("手紙を書いたことはありますか？",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
      body: Text(
        "手紙を貰ったことはありますか？",
        style: TextStyle(fontSize: 16.0),
      ),
      mainImage: Icon(Icons.mail, size: 200.0, color: Colors.white),
    ),
    PageViewModel(
      pageColor: Colors.green,
      bubble: Icon(Icons.hourglass_empty, size: 30.0, color: Colors.white),
      title: Text("ゆっくりとした時間の大切さ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
      body: Text(
        "スピードや効率も大切ですが、ゆっくりとした場所をゆっくりとした場所として守ることもとても大切です。",
        style: TextStyle(fontSize: 16.0),
      ),
      mainImage: Icon(Icons.spa, size: 200.0, color: Colors.white),
    ),
    PageViewModel(
      pageColor: Colors.orange,
      bubble: Icon(Icons.favorite, size: 30.0, color: Colors.white),
      title: Text("デジタルひきゃくについて",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
      body: Text(
        "ドタバタと日々を生きるみなさんにゆっくりとした時間と気持ちを提供したい、そんな思いで作られました。",
        style: TextStyle(fontSize: 16.0),
      ),
      mainImage: Icon(Icons.favorite_outline, size: 200.0, color: Colors.white),
    ),
    PageViewModel(
      pageColor: Colors.purple,
      bubble: Icon(Icons.send, size: 30.0, color: Colors.white),
      title: Text("最初の手紙",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
      body: Text(
        "この手紙を皮切りに、沢山の人に手紙が繋がっていきますように。",
        style: TextStyle(fontSize: 16.0),
      ),
      mainImage: Icon(Icons.mail_outline, size: 200.0, color: Colors.white),
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
