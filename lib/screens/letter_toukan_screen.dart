import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'letter_sent_screen.dart'; // 投函完了画面のインポート

class LetterToukanScreen extends StatelessWidget {
  final String recipientId;
  final String recipientName;
  final String content;

  const LetterToukanScreen({
    Key? key,
    required this.recipientId,
    required this.recipientName,
    required this.content,
  }) : super(key: key);

  Future<void> _sendLetter(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です。')),
      );
      return;
    }

    try {
      final response = await supabase
          .from('letters')
          .insert({
            'sender_id': userId,
            'recipient_id': recipientId,
            'content': content,
            'distance_required': 0, // 必要に応じて適切な値を設定
          });

      // エラーチェックを削除し、try-catchブロックでエラーハンドリングを行う
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LetterSentScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('手紙の送信に失敗しました: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('投函する'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/icons/toukan_tegami.png',
                  width: 400, // 画像の幅を調整
                  height: 400, // 画像の高さを調整
                  fit: BoxFit.contain, // 画像のフィット方法を設定
                ),
                Text(
                  recipientName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // テキストの色を設定
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendLetter(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                '手紙を投函する',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}