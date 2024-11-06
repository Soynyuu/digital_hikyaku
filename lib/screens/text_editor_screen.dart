// ファイル名: text_editor_screen.dart
import 'package:flutter/material.dart';
import 'letter_close_screen.dart'; // 送信完了画面のインポート

class TextEditorScreen extends StatefulWidget {
  final String recipient;
  const TextEditorScreen({Key? key, required this.recipient}) : super(key: key);

  @override
  _TextEditorScreenState createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendLetter() {
    String message = _controller.text;
    if (message.isNotEmpty) {
      // ここに送信処理を追加
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メッセージを送信しました。')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LetterCloseScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メッセージを入力してください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 背景画像とテキストフィールドのサイズを設定
    final containerWidth = screenWidth * 0.9;
    final containerHeight = screenHeight * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.recipient} への手紙'),
      ),
      body: Center(
        child: Stack(
          children: [
            // 背景画像を配置
            Container(
              width: containerWidth,
              height: containerHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/haikei.png'),
                  fit: BoxFit.cover, // 画像をコンテナに合わせてカバー
                ),
                borderRadius: BorderRadius.circular(10.0), // 角を丸くする（オプション）
              ),
            ),
            // テキストフィールドを重ねる
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(20.0), // コンテナ内の余白を設定
                child: Container(
                  decoration: BoxDecoration(
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: 'ここに手紙の内容を書いてください',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.0), // 背景色を透明に
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _sendLetter,
                        child: Text('送信'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
