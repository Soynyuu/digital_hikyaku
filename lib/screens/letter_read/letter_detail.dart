import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/letter.dart';
import '../../services/api_service.dart';
import '../../widgets/background_scaffold.dart';

class LetterDetailScreen extends StatefulWidget {
  final Letter letter;

  const LetterDetailScreen({super.key, required this.letter});

  @override
  _LetterDetailScreenState createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      backgroundImage: 'assets/letter_set/${widget.letter.letterSet}.png', // 追加
      appBar: AppBar(
        title: Text('手紙', style: GoogleFonts.sawarabiMincho()),
        backgroundColor: Colors.transparent, // 追加
        elevation: 0, // 追加
      ),
      body: Center( // 修正: PaddingとSingleChildScrollViewをCenterに変更
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 追加: 内容を中央に配置
              crossAxisAlignment: CrossAxisAlignment.center, // 修正: 中央揃え
              children: [
                Text(
                  widget.letter.content, // ダミーデータの内容を直接表示
                  style: GoogleFonts.sawarabiMincho(fontSize: 16),
                  textAlign: TextAlign.left, // 追加: テキストを中央揃え
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
