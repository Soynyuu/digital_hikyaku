import 'package:flutter/material.dart';

class LetterReadScreen extends StatefulWidget {
  const LetterReadScreen({super.key});

  @override
  State<LetterReadScreen> createState() => _LetterReadScreenState();
}

class _LetterReadScreenState extends State<LetterReadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '手紙を読む',
              style: TextStyle(fontSize: 24),
            ),
            // ここに手紙を読むための UI コンポーネントを追加していきます
          ],
        ),
      ),
    );
  }
}
