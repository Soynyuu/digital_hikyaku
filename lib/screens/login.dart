import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 追加: GoogleFontsパッケージをインポート
import '../services/api_service.dart';
import 'bottombar.dart';
import 'dart:convert';
import '../widgets/background_scaffold.dart';
import 'registar.dart'; // 追加: 登録画面をインポート

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiService.login(
      _nameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomBar()),
      );
    } else {
      final body = jsonDecode(response.body);
      setState(() {
        _errorMessage = body['error'] ?? 'ログインに失敗しました';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
        backgroundColor: Colors.transparent, // 変更なし
        elevation: 0, // 変更なし
        iconTheme: IconThemeData(color: Colors.white), // 追加: アイコンの色を白に設定
        titleTextStyle: GoogleFonts.sawarabiMincho(
            color: Colors.white, fontSize: 20), // 変更: GoogleFonts.sawarabiMinchoを使用
      ),
      // ...existing code...
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ユーザ名'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('ログイン'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('アカウントをお持ちでない方はこちら'),
              ),
            ],
          ),
        ),
      ),
// ...existing code...
    );
  }
}