import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'select_recipient.dart';

class LetterWriteScreen extends StatelessWidget {
  const LetterWriteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectRecipientScreen(),
          ),
        );
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "手紙\nを",
              style: GoogleFonts.sawarabiMincho(
                fontSize: 30,
                color: Color(0xFF8F8F8F),
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: "\n書く",
              style: GoogleFonts.sawarabiMincho(
                fontSize: 36,
                color: Color(0xFF542E00),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
