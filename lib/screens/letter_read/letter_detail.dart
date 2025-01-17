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
  String? _content;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLetterContent();
  }

  Future<void> _loadLetterContent() async {
    if (!widget.letter.isArrived) {
      setState(() {
        _error = 'この手紙はまだ開封できません';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.readLetter(widget.letter.id);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _content = data['content'];
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _error = error['error'] ?? '手紙を開封できませんでした';
        });
      }
    } catch (e) {
      setState(() {
        _error = '通信エラーが発生しました';
      });
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
        title: Text('手紙', style: GoogleFonts.sawarabiMincho()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(
                child: Text(_error!, style: GoogleFonts.sawarabiMincho(color: Colors.red)),
              )
            : SingleChildScrollView(
                child: Text(
                  _content ?? '',
                  style: GoogleFonts.sawarabiMincho(fontSize: 16),
                ),
              ),
      ),
    );
  }
}
