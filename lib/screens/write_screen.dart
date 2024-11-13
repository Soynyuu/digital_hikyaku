import 'package:flutter/material.dart';
import 'select_recipient_screen.dart'; // 宛先選択ページのインポート

class WriteScreen extends StatelessWidget {
  const WriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAFFD3), // 背景色を設定
      body: Center(
        child: InkWell(
          onTap: () {
            // ボタンがタップされたときの処理
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SelectRecipientScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0), // 定数に変更
            child: Image.asset(
              'assets/icons/new-write.png',
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
