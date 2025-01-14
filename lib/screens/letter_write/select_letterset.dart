import 'package:flutter/material.dart';
import '../../widgets/background_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectLettersetScreen extends StatefulWidget {
  const SelectLettersetScreen({super.key});

  @override
  _SelectLettersetScreenState createState() => _SelectLettersetScreenState();
}

class _SelectLettersetScreenState extends State<SelectLettersetScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          'レターセットを選択',
          style: GoogleFonts.sawarabiMincho(
            color: Colors.brown,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent, // AppBarを透明に設定
        elevation: 0, // AppBarの影をなくす
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'レターセットの選択画面',
            style: GoogleFonts.sawarabiMincho(
              color: Colors.brown,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}