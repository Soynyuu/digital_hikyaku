import 'package:flutter/material.dart';
import '../../models/letter.dart'; // 新規追加: Letterモデルをインポート
import 'package:google_fonts/google_fonts.dart';

class LetterReadScreen extends StatelessWidget {
  final Letter letter; // 新規追加: 手紙データを受け取る

  const LetterReadScreen({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(letter.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('差出人: ${letter.sender}',
                style: GoogleFonts.sawarabiMincho(fontSize: 18)),
            const SizedBox(height: 20),
            Text(
              letter.content,
              style: GoogleFonts.sawarabiMincho(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
