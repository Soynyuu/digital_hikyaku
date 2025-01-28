import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_letter.dart'; // 追加: PostLetterScreenをインポート
import '../../widgets/background_scaffold.dart';

class SealedLetterScreen extends StatelessWidget {
  final String recipient;

  const SealedLetterScreen({super.key, required this.recipient});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          '手紙を閉じる',
          style: GoogleFonts.sawarabiMincho(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostLetterScreen(recipient: recipient),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/icons/close_letter.png', // 変更: 画像パスをletter.pngに変更
                    width: 400,
                    height: 400,
                  ),
                ),
                Center( // 変更: PositionedからCenterに変更
                  child: Text(
                    '封を閉じるには\n手紙をタップ',
                    style: GoogleFonts.sawarabiMincho(
                      color: Color(0xFF542E00),
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}