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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text('手紙', style: GoogleFonts.sawarabiMincho()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '受信者: ${widget.letter.recipientName}',
                style: GoogleFonts.sawarabiMincho(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'レターセット: ${widget.letter.letterSet}',
                style: GoogleFonts.sawarabiMincho(
                    fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/letter_set/${widget.letter.letterSet}.png',
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Text(
                widget.letter.content, // ダミーデータの内容を直接表示
                style: GoogleFonts.sawarabiMincho(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
