import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'check_letter.dart'; // 追加: プレビュー画面をインポート

class EditLetterScreen extends StatefulWidget { // 修正: StatelessWidgetからStatefulWidgetへ変更
  final String backgroundImage;

  const EditLetterScreen({super.key, required this.backgroundImage});

  @override
  _EditLetterScreenState createState() => _EditLetterScreenState();
}

class _EditLetterScreenState extends State<EditLetterScreen> {
  final TextEditingController _textController = TextEditingController(); // 追加: テキストコントローラー

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像の設定
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // テキストフィールドのオーバーレイ
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController, // 修正: コントローラーを設定
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'ここに手紙を書いてください',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.0),
                ),
                style: GoogleFonts.sawarabiMincho(fontSize:18), // 修正: 直接styleプロパティに設定
              ),
            ),
          ),
          // プレビューおよび閉じるボタンの追加
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckLetterScreen(
                          backgroundImage: widget.backgroundImage,
                          letterText: _textController.text,
                        ),
                      ),
                    );
                  },
                  child: Text('プレビュー'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
