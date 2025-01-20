import 'package:digital_hikyaku/widgets/background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sealed_letter.dart'; // 追加: SealedLetterScreenをインポート

class CheckLetterScreen extends StatelessWidget {
  final String backgroundImage;
  final String letterText;
  final String recipient;

  const CheckLetterScreen({
    super.key,
    required this.backgroundImage,
    required this.letterText,
    required this.recipient,
  });

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          '手紙の確認',
          style: GoogleFonts.sawarabiMincho(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
          // 手紙の内容の表示
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                letterText,
                style: GoogleFonts.sawarabiMincho(
                  fontSize: 18,
                  color: Colors.black,
                  backgroundColor: Colors.white.withOpacity(0.0),
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          // 封を完了するボタンの追加
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SealedLetterScreen(recipient: recipient),
                  ),
                );
              },
              child: Text('封を閉じる'),
            ),
          ),
        ],
      ),
    );
  }
}
