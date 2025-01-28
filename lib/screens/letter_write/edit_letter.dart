import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'check_letter.dart';

class EditLetterScreen extends StatefulWidget {
  final String backgroundImage;
  final String recipientId;
  final String recipientName;

  const EditLetterScreen({
    super.key, 
    required this.backgroundImage,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  _EditLetterScreenState createState() => _EditLetterScreenState();
}

class _EditLetterScreenState extends State<EditLetterScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'ここに手紙を書いてください',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.0),
                ),
                style: GoogleFonts.sawarabiMincho(fontSize: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckLetterScreen(
                          backgroundImage: widget.backgroundImage,
                          letterText: _textController.text,
                          recipientId: widget.recipientId,
                          recipientName: widget.recipientName,
                        ),
                      ),
                    );
                  },
                  child: Text('筆を置く'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
