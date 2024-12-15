import 'package:flutter/material.dart';
import 'letter_close_screen.dart';

class TextEditorScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const TextEditorScreen({
    Key? key,
    required this.recipientId,
    required this.recipientName,
  }) : super(key: key);

  @override
  _TextEditorScreenState createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.recipientName} に送る手紙'),
      ),
      body: Stack(
        children: [
          // 背景画像を設定
          Image.asset(
            'assets/icons/haikei.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // テキストエディタを重ねる
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: '例えば、クリスマスカードを書いてみましょう。',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.0), // 背景を半透明に
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LetterCloseScreen(
                          recipientId: widget.recipientId,
                          recipientName: widget.recipientName,
                          content: _controller.text,
                        ),
                      ),
                    );
                  },
                  child: Text('手紙を封筒に入れる'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
