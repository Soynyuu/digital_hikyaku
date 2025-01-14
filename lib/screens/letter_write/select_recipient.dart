import 'package:flutter/material.dart';
import '../../widgets/background_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'select_letterset.dart';

class SelectRecipientScreen extends StatefulWidget {
  const SelectRecipientScreen({super.key});

  @override
  _SelectRecipientScreenState createState() => _SelectRecipientScreenState();
}

class _SelectRecipientScreenState extends State<SelectRecipientScreen> {
  String? selectedRecipient;

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          '宛先を選ぶ',
          style: GoogleFonts.sawarabiMincho(
            color: Colors.brown,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent, // AppBarを透明に設定
        elevation: 0, // AppBarの影をなくす
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8, // 横幅を小さく設定
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.brown, width: 1.0),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRecipient,
                    hint: Text(
                      '送り先を選択',
                      style: GoogleFonts.sawarabiMincho(fontSize: 20),
                    ),
                    items: <String>['ダミー1', 'ダミー2', 'ダミー3']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.sawarabiMincho(fontSize: 20),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRecipient = newValue;
                      });
                    },
                    isExpanded: true,
                    underline: SizedBox(), // デフォルトの下線を削除
                  ),
                ),
              ),
            ),
            if (selectedRecipient != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 16.0), // 右寄せに配置
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'さんへ',
                    style: GoogleFonts.sawarabiMincho(
                      color: Colors.brown,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            Spacer(flex: 1), // ここでスペースを調整
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectLettersetScreen()),
                    );
                  },
                  child: Text('レターセットを選択へ >'
                  , style: GoogleFonts.sawarabiMincho(
                      color: Colors.brown,
                      fontSize: 20,
                    ),),
                ),
              ),
            ),
            Spacer(flex: 2), // ここでスペースを調整
          ],
        ),
      ),
    );
  }
}