import 'package:flutter/material.dart';
import '../../widgets/background_scaffold.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'edit_letter.dart';

class SelectLettersetScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const SelectLettersetScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  _SelectLettersetScreenState createState() => _SelectLettersetScreenState();
}

class _SelectLettersetScreenState extends State<SelectLettersetScreen> {
  final List<Map<String, String>> letterSets = [
    {
      'image': 'assets/letter_set/letter_set_1.png',
      'title': 'チェックメモリー',
      'description': '淡いブルーとオレンジのチェック柄が、どこか懐かしくも爽やかなレターセット。シンプルなデザインで、ビジネスシーンからカジュアルなメッセージまで幅広く使えます。',
    },
    {
      'image': 'assets/letter_set/letter_set_2.png',
      'title': 'ほのぼのフラワー',
      'description': 'やさしいタッチで描かれた黄色い小花が、穏やかな気持ちを届けてくれるレターセット。シンプルながらも温かみのあるデザインで、大切な人への手紙にぴったりです。',
    },
    {
      'image': 'assets/letter_set/letter_set_3.png',
      'title': 'ベーシックレター',
      'description': '落ち着いたチェック柄がアクセントのシンプルな手紙用紙。カジュアルなメッセージからフォーマルな手紙まで、どんなシーンにも馴染む万能デザインです。',
    },
  ];

  String? selectedLetterSet;

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          'レターセットを選択',
          style: GoogleFonts.sawarabiMincho(
            color: Color(0xff3C2100),
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent, // AppBarを透明に設定
        elevation: 0, // AppBarの影をなくす
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              itemCount: letterSets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.asset(
                        letterSets[index]['image']!,
                        width: 150,
                        height: 150,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              letterSets[index]['title']!,
                              style: GoogleFonts.sawarabiMincho(
                                color: Colors.brown,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              letterSets[index]['description']!,
                              style: GoogleFonts.sawarabiMincho(
                                color: Colors.brown,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: selectedLetterSet == letterSets[index]['image'],
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedLetterSet = letterSets[index]['image'];
                            } else {
                              selectedLetterSet = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 128,
              right: 16,
              child: ElevatedButton(
                onPressed: selectedLetterSet != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditLetterScreen(
                              backgroundImage: selectedLetterSet!,
                              recipientId: widget.recipientId,
                              recipientName: widget.recipientName,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  '手紙を書く',
                  style: GoogleFonts.sawarabiMincho(
                    color: Colors.brown,
                    fontSize: 20,
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
