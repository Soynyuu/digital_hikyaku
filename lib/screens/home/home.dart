import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
// フォントはsawarabiMincho
  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
            onPressed: () {},
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "手紙\nを",
                    style: GoogleFonts.sawarabiMincho(
                        fontSize: 30,
                        color: Color(0xFF8F8F8F),
                        decoration: TextDecoration.underline)),
                TextSpan(
                    text: "\nかく",
                    style: GoogleFonts.sawarabiMincho(
                        fontSize: 36,
                        color: Color(0xFF542E00),
                        decoration: TextDecoration.underline)),
              ]),
            )));
  }
}
