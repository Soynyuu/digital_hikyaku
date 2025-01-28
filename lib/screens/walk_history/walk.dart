import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/background_scaffold.dart';

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({super.key});
  @override
  _WalkHistoryScreenState createState() => _WalkHistoryScreenState();
}

class _WalkHistoryScreenState extends State<WalkHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ウォーク履歴', style: GoogleFonts.sawarabiGothic()),
      ),
    );
  }
}
