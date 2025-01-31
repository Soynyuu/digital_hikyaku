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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReceivedLetters();
  }

  Future<void> _fetchReceivedLetters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getReceiveHistory();
      
      if (response.statusCode == 200) {
        final List<dynamic> lettersJson = response.data;
        setState(() {
          _letters = lettersJson.map((letterJson) {
            // 送信者の名前を取得するロジックを追加する必要があります
            return Letter(
              id: letterJson['id'],
              senderId: letterJson['sender_id'],
              recipientId: letterJson['recipient_id'],
              recipientName: letterJson['recipient_name'] ?? '不明',
              letterSet: letterJson['letter_set_id'],
              content: '', // 内容は手紙を開くときに取得
              isArrived: letterJson['is_arrived'] == 1,
              arriveAt: DateTime.parse(letterJson['arrive_at']),
              readFlag: letterJson['read_flag'] == 1,
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load letters');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('手紙の取得に失敗しました: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
