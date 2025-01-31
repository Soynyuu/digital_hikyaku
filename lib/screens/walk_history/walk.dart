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
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text('ウォーク履歴', style: GoogleFonts.sawarabiGothic()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '散歩記録画面は開発中です',
            style: GoogleFonts.sawarabiGothic(
              fontSize: 18,
              color: Colors.brown.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
