import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/background_scaffold.dart';
import '../home/home.dart'; // HomeScreenをインポート
import '../../models/letter.dart'; // Letterクラスをインポート

class PostLetterScreen extends StatelessWidget {
  final String recipient;

  const PostLetterScreen({super.key, required this.recipient});

  void _postLetter(BuildContext context) {
    // 手紙を投函する処理をここに実装
    // 例: API呼び出しや確認ダイアログの表示
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('投函完了', style: GoogleFonts.sawarabiMincho()),
        content: Text('手紙が投函されました。', style: GoogleFonts.sawarabiMincho()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ダイアログを閉じる
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              ); // HomeScreenに遷移
            },
            child: Text('OK', style: GoogleFonts.sawarabiMincho()),
          ),
        ],
      ),
    );

    // ダミーの手紙を作成する場合、すべての必要なフィールドを提供します
    Letter dummyLetter = Letter(
      id: '3',
      senderId: 'sender_3',
      recipientId: 'recipient_3',
      recipientName: '田中 一郎', // 新規追加
      letterSet: 'セットC',         // 新規追加
      content: 'これは投稿されたダミー手紙です。',
      isArrived: true,
      arriveAt: DateTime.now(),
      readFlag: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          '手紙を投函する',
          style: GoogleFonts.sawarabiMincho(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => _postLetter(context),
              child: Image.asset(
                'assets/icons/letter.png',
                width: 600,
                height: 600,
              ),
            ),
            Positioned(
              top: 20,
              child: Text(
                '宛先: $recipient',
                style: GoogleFonts.sawarabiMincho(
                  fontSize: 24,
                  color: Colors.brown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
