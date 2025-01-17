
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/background_scaffold.dart';

class PostLetterScreen extends StatelessWidget {
  const PostLetterScreen({super.key});

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
              Navigator.popUntil(context, (route) => route.isFirst); // 最初の画面に戻る
            },
            child: Text('OK', style: GoogleFonts.sawarabiMincho()),
          ),
        ],
      ),
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
        child: GestureDetector(
          onTap: () => _postLetter(context),
          child: Image.asset(
            'assets/icons/letter.png',
            width: 600,
            height: 600,
          ),
        ),
      ),
    );
  }
}