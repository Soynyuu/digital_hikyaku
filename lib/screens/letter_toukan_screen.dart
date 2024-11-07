import 'package:flutter/material.dart';

class LetterToukanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('投函完了'),
      ),
      body: Center(
        child: Image.asset(
          'assets/icons/toukan_tegami.png',
          width: 400, // 画像の幅を調整
          height: 400, // 画像の高さを調整
          fit: BoxFit.contain, // 画像のフィット方法を設定
        ),
      ),
    );
  }
}