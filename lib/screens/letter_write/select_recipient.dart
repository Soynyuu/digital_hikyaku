import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart'

class SelectRecipientScreen extends StatelessWidget {
  const SelectRecipientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = ['Recipient A', 'Recipient B', 'Recipient C'];
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '宛先を選択',
            style: GoogleFonts.sawarabiMincho(
              color: Color(0xFF542E00),
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF542E00),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: DropdownButton<String>(
            // value: items.first,
            underline: Container(
              height: 1, // アンダーラインの太さ
              color: Color(0xFF542E00), // アンダーラインの色
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.sawarabiMincho(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
            },
          ),
        ),
      ),
    );
  }
}
