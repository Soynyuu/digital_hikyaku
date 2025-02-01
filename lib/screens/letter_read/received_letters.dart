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

  String _formatArriveAt(DateTime arriveAt) {
    final now = DateTime.now();
    final difference = arriveAt.difference(now).inDays;
    
    if (difference == 0) return "今日中";
    if (difference == 1) return "明日";
    if (difference == 2) return "明後日";
    if (difference <= 7) return "${difference}日後";
    
    return "約${(difference / 7).round()}週間後";
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text('受信した手紙', style: GoogleFonts.sawarabiMincho()),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                String letterStatus = letter.isArrivedNow()
                  ? (letter.readFlag ? '既読の手紙' : '届いた手紙')
                  : '配達中の手紙';
                
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      letterStatus,
                      style: GoogleFonts.sawarabiMincho(),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '送信者: ${letter.senderName}',
                          style: GoogleFonts.sawarabiMincho(),
                        ),
                        if (!letter.isArrivedNow()) Text(
                          '到着予定: ${_formatArriveAt(letter.arriveAt)}',
                          style: GoogleFonts.sawarabiMincho(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: letter.readFlag 
                      ? const Icon(Icons.mark_email_read)
                      : letter.isArrivedNow()
                          ? const Icon(Icons.mail)
                          : const Icon(Icons.schedule),
                    onTap: () {
                      if (!letter.isArrivedNow()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('この手紙はまだ配達中です。到着までお待ちください。'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
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
