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
  String _content = '';

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
      } else {
        throw Exception('手紙の読み込みに失敗しました');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('手紙の読み込みに失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      backgroundImage: 'assets/letter_set/${widget.letter.letterSet}.png',
      appBar: AppBar(
        title: Text('手紙', style: GoogleFonts.sawarabiMincho()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _content,
                      style: GoogleFonts.sawarabiMincho(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
