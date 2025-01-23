import 'package:digital_hikyaku/widgets/background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/background_scaffold.dart';

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({super.key});

  @override
  _WalkHistoryScreenState createState() => _WalkHistoryScreenState();
}

class _WalkHistoryScreenState extends State<WalkHistoryScreen> {
  String _locationMessage = "現在の位置を取得しています...";
  double _currentSteps = 7000;
  final double _requiredSteps = 10000;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 位置情報サービスが有効かどうかを確認
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "位置情報サービスが無効です。";
      });
      return;
    }

    // 位置情報の権限を確認
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "位置情報の権限が拒否されました。";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "位置情報の権限が永久に拒否されました。";
      });
      return;
    }

    // 現在の位置を取得
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _locationMessage = "緯度: ${position.latitude}, 経度: ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text('ウォーク履歴', style: GoogleFonts.sawarabiGothic()),
      ),
      body: SafeArea(
        // SafeAreaを追加
        child: Padding(
          padding: const EdgeInsets.all(16.0), // パディングを調整
          child: ListView(
            // ColumnをListViewに変更
            children: [
              Card(
                // プログレスバーをCardで囲む
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _currentSteps / _requiredSteps,
                        minHeight: 20, // プログレスバーを太く
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${_currentSteps.toInt()}歩 / $_requiredSteps歩',
                        style: GoogleFonts.sawarabiMincho(fontSize: 16),
                      ),
                      Text(
                        'Sechack子ちゃんへの手紙を届けるのに必要な歩数',
                        style: GoogleFonts.sawarabiMincho(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              SizedBox(height: 20),
              Card(
                // ボタンをCardで囲む
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _currentSteps >= _requiredSteps
                        ? () {
                            // 手紙を送信する処理をここに追加
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('手紙が送信されました！')),
                            );
                          }
                        : null,
                    child: Text('手紙を送る'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
