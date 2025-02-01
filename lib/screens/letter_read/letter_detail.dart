import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/letter.dart';
import '../../services/api_service.dart';
import '../../widgets/background_scaffold.dart';

class LetterDetailScreen extends StatefulWidget {
  final Letter letter;

  const LetterDetailScreen({super.key, required this.letter});

  @override
  _LetterDetailScreenState createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _content; // nullの場合「未開封」を表示

  @override
  void initState() {
    super.initState();
    _loadLetterContent();
  }

  Future<void> _loadLetterContent() async {
    try {
      final response = await _apiService.readLetter(widget.letter.id);
      
      if (response.statusCode == 200) {
        setState(() {
          _content = response.data['content'];
          _isLoading = false;
        });
        return;
      }

      String errorMessage;
      if (response.data is Map) {
        errorMessage = response.data['error'] ?? '不明なエラーが発生しました';
      } else {
        errorMessage = 'サーバーエラーが発生しました';
      }

      if (errorMessage.contains('この手紙はまだ配達中です')) {
        setState(() {
          _isLoading = false;
          _content = 'この手紙はまだ配達中です。到着までお待ちください。';
        });
      } else {
        setState(() {
          _isLoading = false;
          _content = 'エラーが発生しました。\nしばらく待ってから再度お試しください。';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _content = 'エラーが発生しました。\nしばらく待ってから再度お試しください。';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          '手紙',
          style: GoogleFonts.sawarabiMincho(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 背景画像
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/letter_set/${widget.letter.letterSet}.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 手紙内容の表示
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400 - 135,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _content ?? '',
                          style: GoogleFonts.sawarabiMincho(fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
