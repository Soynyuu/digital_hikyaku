// ファイル名: select_recipient_screen.dart
import 'package:flutter/material.dart';
import 'text_editor_screen.dart'; // テキストエディタ画面のインポート

class SelectRecipientScreen extends StatefulWidget {
  @override
  _SelectRecipientScreenState createState() => _SelectRecipientScreenState();
}

class _SelectRecipientScreenState extends State<SelectRecipientScreen> {
  String? _selectedRecipient;
  final List<String> _recipients = ['宛先1', '宛先2', '宛先3', '宛先4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('宛先選択'),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            Image.asset(
              'assets/icons/select.png',
              width: 300,
              height: 300,
            ),
            Positioned(
              top: 100, // ドロップダウンの位置調整
              left: 50,
              right: 50,
              child: DropdownButton<String>(
                isExpanded: true, // ドロップダウンを横幅いっぱいに広げる
                value: _selectedRecipient,
                hint: Text('宛先を選択'),
                items: _recipients.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRecipient = newValue;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 10, // 画像の下からの距離
              right: 10, // 画像の右からの距離
              child: InkWell(
                onTap: () {
                  if (_selectedRecipient != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TextEditorScreen(recipient: _selectedRecipient!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('宛先を選択してください。'),
                      ),
                    );
                  }
                },
                child: Image.asset(
                  'assets/icons/kaku.png',
                  width: 100, // ボタンのサイズを調整
                  height: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
