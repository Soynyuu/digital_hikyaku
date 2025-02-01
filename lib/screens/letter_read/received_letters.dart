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
          _letters = lettersJson.map((json) => Letter.fromJson(json)).toList();
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
                      '送信者: ${letter.senderName}',
                      style: GoogleFonts.sawarabiMincho(),
                    ),
                    trailing: letter.readFlag 
                      ? const Icon(Icons.mark_email_read)
                      : letter.isArrived 
                          ? const Icon(Icons.mail)
                          : const Icon(Icons.schedule),
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
