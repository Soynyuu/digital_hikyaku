import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/background_scaffold.dart';
import 'bottombar.dart'; // 追加: BottomBarをインポート
import 'package:digital_hikyaku/services/geo_api_service.dart'; // GeoApiServiceをインポート

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _zipController = TextEditingController(); // 郵便番号コントローラーを追加
  final GeoApiService _geoApiService = GeoApiService(); // GeoApiServiceのインスタンスを作成
  String? _errorMessage;
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_zipController.text.isEmpty) {
        throw Exception('郵便番号を入力してください');
      }

      // 郵便番号から緯度と経度を取得
      List<ZipCodeResult> results;
      try {
        results = await _geoApiService.searchZipCode(_zipController.text);
      } catch (e) {
        throw Exception('郵便番号の検索に失敗しました: ${e.toString()}');
      }

      if (results.isEmpty) {
        throw Exception('入力された郵便番号が見つかりませんでした');
      }

      final double latitude = results[0].y; // 緯度
      final double longitude = results[0].x; // 経度

      // 小数点以下6桁に丸める
      final roundedLatitude = double.parse(latitude.toStringAsFixed(6));
      final roundedLongitude = double.parse(longitude.toStringAsFixed(6));

      final response = await _apiService.register(
        _nameController.text,
        _displayNameController.text,
        _passwordController.text,
        roundedLongitude,
        roundedLatitude,
      );

      if (response.statusCode == 200) {
        // 登録成功後にログイン処理を実行
        final loginResponse = await _apiService.login(
          _nameController.text,
          _passwordController.text,
        );

        if (loginResponse.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomBar()),
          );
        } else {
          final body = jsonDecode(loginResponse.body);
          setState(() {
            _errorMessage = body['error'] ?? 'ログインに失敗しました';
          });
        }
      } else {
        final body = jsonDecode(response.body);
        setState(() {
          _errorMessage = body['error'] ?? '登録に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('アカウント登録'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ユーザー名'),
              ),
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: '表示名'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
              TextField(
                controller: _zipController,
                decoration: const InputDecoration(labelText: '郵便番号'), // 郵便番号入力フィールドを追加
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _zipController.dispose(); // 郵便番号コントローラーを破棄
    _nameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
