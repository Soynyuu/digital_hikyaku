import 'package:flutter/material.dart';

class EditLetterScreen extends StatelessWidget {
  final String backgroundImage;

  const EditLetterScreen({super.key, required this.backgroundImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像の設定
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // テキストフィールドのオーバーレイ
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'ここに手紙を書いてください',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.0),
                ),
              ),
            ),
          ),
          // 閉じるボタンの追加
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('閉じる'),
            ),
          ),
        ],
      ),
    );
  }
}
