import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/letter.dart';
import '../../services/api_service.dart';
import 'letter_detail.dart';
import '../../widgets/background_scaffold.dart';

class ReceivedLettersScreen extends StatefulWidget {
  const ReceivedLettersScreen({super.key});

  @override
  _ReceivedLettersScreenState createState() => _ReceivedLettersScreenState();
}

class _ReceivedLettersScreenState extends State<ReceivedLettersScreen> {
  final ApiService _apiService = ApiService();
  List<Letter> _letters = [];

  @override
  void initState() {
    super.initState();
    _fetchReceivedLetters();
  }

  Future<void> _fetchReceivedLetters() async {
    // ダミーデータを使用
    setState(() {
      _letters = [
        Letter(
          id: '1',
          senderId: 'sender_1',
          recipientId: 'recipient_1',
          recipientName: 'Sechackくん', // 新規追加
          letterSet: 'letter_set_2',         // 新規追加
          isArrived: true,
          arriveAt: DateTime.now(),
          readFlag: false,
          content: 'sechackちゃんへ\n\n\n\nこんにちは、sechackくんと申します。\nこれからよろしくお願いします。\n\n\n\n\nSechackくんより',
        ),
        Letter(
          id: '2',
          senderId: 'sender_2',
          recipientId: 'recipient_2',
          recipientName: 'sechackちゃん', // 新規追加
          letterSet: 'letter_set_2',         // 新規追加
          isArrived: false,
          arriveAt: DateTime.now().add(Duration(days: 1)),
          readFlag: false,
          content: 'もう一つのダミー手紙。',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text('受信した手紙', style: GoogleFonts.sawarabiMincho()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchReceivedLetters,
        child: _letters.isEmpty
          ? Center(
              child: Text(
                '手紙が届いていません',
                style: GoogleFonts.sawarabiMincho(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _letters.length,
              itemBuilder: (context, index) {
                final letter = _letters[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      letter.isArrived ? '届いた手紙' : '配達中の手紙',
                      style: GoogleFonts.sawarabiMincho(),
                    ),
                    subtitle: Text(
                      '受信者: ${letter.recipientName}',
                      style: GoogleFonts.sawarabiMincho(),
                    ),
                    trailing: letter.readFlag 
                      ? const Icon(Icons.mark_email_read)
                      : const Icon(Icons.mail),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LetterDetailScreen(letter: letter),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      ),
    );
  }
}
