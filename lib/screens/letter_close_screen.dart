import 'package:flutter/material.dart';
import 'letter_toukan_screen.dart'; // 投函完了画面のインポート

class LetterCloseScreen extends StatelessWidget {
  final String recipientId;
  final String recipientName;
  final String content;

  const LetterCloseScreen({
    Key? key,
    required this.recipientId,
    required this.recipientName,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('書き終えた'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LetterToukanScreen(
                  recipientId: recipientId,
                  recipientName: recipientName,
                  content: content,
                ),
              ),
            );
          },
          child: Image.asset(
            'assets/icons/tegami_close.png',
            width: 400, // 画像の幅を調整
            height: 400, // 画像の高さを調整
            fit: BoxFit.contain, // 画像のフィット方法を設定
          ),
        ),
      ),
    );
  }
}
