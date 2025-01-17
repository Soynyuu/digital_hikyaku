import 'package:flutter/material.dart';
import '../../widgets/background_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_letter.dart';

class SelectLettersetScreen extends StatefulWidget {
  const SelectLettersetScreen({super.key});

  @override
  _SelectLettersetScreenState createState() => _SelectLettersetScreenState();
}

class _SelectLettersetScreenState extends State<SelectLettersetScreen> {
  final List<Map<String, String>> letterSets = [
    {
      'image': 'assets/letter_set/letter_set_1.png',
      'title': 'デザイン1',
      'description': 'デザイン1の説明文',
    },
    {
      'image': 'assets/letter_set/letter_set_2.png',
      'title': 'デザイン2',
      'description': 'デザイン2の説明文',
    },
    {
      'image': 'assets/letter_set/letter_set_3.png',
      'title': 'デザイン3',
      'description': 'デザイン3の説明文',
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
