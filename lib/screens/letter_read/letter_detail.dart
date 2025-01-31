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
    if (!widget.letter.isArrived) {
      setState(() {
        _isLoading = false;
      });
      
      final now = DateTime.now();
      final remainingTime = widget.letter.arriveAt.difference(now);
      final hours = remainingTime.inHours;
      final minutes = remainingTime.inMinutes % 60;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '手紙はまだ到着していません。\n到着まであと約$hours時間$minutes分です',
            style: GoogleFonts.sawarabiGothic(),
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.brown,
        ),
      );
      
      Navigator.pop(context);
      return;
    }

    try {
      final response = await _apiService.readLetter(widget.letter.id);
      
      if (response.statusCode == 200) {
        setState(() {
          _content = response.data['content'];
          _isLoading = false;
        });
      } else {
        throw Exception(response.data['error'] ?? '手紙の読み込みに失敗しました');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('手紙の読み込みに失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      backgroundImage: 'assets/letter_set/${widget.letter.letterSet}.png',
      appBar: AppBar(
        title: Text(
          widget.letter.isArrived ? '手紙' : '配達中の手紙',
          style: GoogleFonts.sawarabiMincho(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              )
            : widget.letter.isArrived
                ? Padding(
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
                  )
                : _buildNotArrivedMessage(),
      ),
    );
  }

  Widget _buildNotArrivedMessage() {
    final now = DateTime.now();
    final remainingTime = widget.letter.arriveAt.difference(now);
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.schedule,
          size: 64,
          color: Colors.brown.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          '手紙はまだ配達中です',
          style: GoogleFonts.sawarabiMincho(
            fontSize: 20,
            color: Colors.brown.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '到着まであと約$hours時間$minutes分',
          style: GoogleFonts.sawarabiMincho(
            fontSize: 16,
            color: Colors.brown.shade600,
          ),
        ),
      ],
    );
  }
}
