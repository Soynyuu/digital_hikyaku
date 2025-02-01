import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_letter.dart'; // 追加: PostLetterScreenをインポート
import '../../widgets/background_scaffold.dart';

class SealedLetterScreen extends StatelessWidget {
  final String recipientId;
  final String recipientName;
  final String letterText;
  final String letterSetId;

  const SealedLetterScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.letterText,
    required this.letterSetId,
  });

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
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Stack(
              alignment: Alignment.center, // Stack内要素を中央に配置
              children: [
                // 画像を下層に表示
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostLetterScreen(
                          recipientId: recipientId,
                          recipientName: recipientName,
                          letterText: letterText,
                          letterSetId: letterSetId,
                        ),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/icons/close_letter.png',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ),
                // テキストを画像の上に重ねる
                Text(
                  '封を閉じるには\n手紙をタップ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sawarabiMincho(
                    color: Color(0xFF542E00),
                    fontSize: 20,
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
