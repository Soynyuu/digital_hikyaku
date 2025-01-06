import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/background_scaffold.dart';
import 'login.dart';
import 'bottombar.dart'; // 追加: BottomBarをインポート

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
  String? _errorMessage;
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiService.register(
      _nameController.text,
      _displayNameController.text,
      _passwordController.text,
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

    setState(() {
      _isLoading = false;
    });
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
}
