import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/background_scaffold.dart';
import '../../models/letter.dart';
import '../../services/api_service.dart';
import '../bottombar.dart';

class PostLetterScreen extends StatelessWidget {
  final String recipientId;
  final String recipientName;
  final String letterText;
  final String letterSetId;

  const PostLetterScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.letterText,
    required this.letterSetId,
  });

  void _postLetter(BuildContext context) async {
    try {
      final apiService = ApiService();
      final response = await apiService.createLetter(
        recipientId,
        letterText,
        letterSetId.split('/').last.split('.').first, // ファイル名から拡張子を除いたものをIDとして使用
      );

      // レスポンスデータを直接使用
      final responseData = response.data; // jsonDecode を削除
      
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('投函完了', style: GoogleFonts.sawarabiMincho()),
            content: Text(responseData['message'] ?? '手紙が投函されました。', 
              style: GoogleFonts.sawarabiMincho()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ダイアログを閉じる
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => BottomBar(
                        initialIndex: 0, // ホームタブを選択
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: Text('OK', style: GoogleFonts.sawarabiMincho()),
              ),
            ],
          ),
        );
      } else {
        String errorMessage = responseData['error'] ?? '手紙の投函に失敗しました。';
        // デバッグ用にステータスコードも表示
        debugPrint('Error status code: ${response.statusCode}');
        debugPrint('Error message: $errorMessage');
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('エラー', style: GoogleFonts.sawarabiMincho()),
            content: Text('$errorMessage\n(エラーコード: ${response.statusCode})', 
              style: GoogleFonts.sawarabiMincho()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: GoogleFonts.sawarabiMincho()),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('エラー', style: GoogleFonts.sawarabiMincho()),
          content: Text('手紙の投函中にエラーが発生しました。', style: GoogleFonts.sawarabiMincho()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ダイアログを閉じる
              },
              child: Text('OK', style: GoogleFonts.sawarabiMincho()),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          '手紙を投函する',
          style: GoogleFonts.sawarabiMincho(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => _postLetter(context),
              child: Image.asset(
                'assets/icons/letter.png',
                width: 600,
                height: 600,
              ),
            ),
            Positioned(
              top: 20,
              child: Text(
                '宛先: $recipientName',
                style: GoogleFonts.sawarabiMincho(
                  fontSize: 24,
                  color: Colors.brown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
