import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../widgets/background_scaffold.dart';
import 'check_letter.dart';
import 'dart:html' as html; // Web用のimportを追加
import 'package:flutter/foundation.dart' show kIsWeb;

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _previousText = '';
  html.AudioElement? _webAudioElement; // Web用のAudio要素

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    if (kIsWeb) {
      _webAudioElement = html.AudioElement('assets/assets/audios/pen.mp3');
    } else {
      await _audioPlayer.setAsset('assets/audios/pen.mp3');
    }

    _textController.addListener(() {
      if (_textController.text.length > _previousText.length) {
        if (kIsWeb) {
          _webAudioElement?.currentTime = 0;
          _webAudioElement?.play();
        } else {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        }
      }
      _previousText = _textController.text;
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _audioPlayer.dispose();
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text('手紙を書く', style: GoogleFonts.sawarabiMincho()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 背景画像を表示
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.backgroundImage),
                fit: BoxFit.contain, // 背景画像全体を表示
              ),
            ),
          ),
          // 入力領域
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400 - 135, // 変更: 幅 = 400 - 135
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  textAlign: TextAlign.left, // 左揃え
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
          ),
          // 下部のボタン
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
