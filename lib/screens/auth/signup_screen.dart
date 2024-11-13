import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      try {
        // ユーザーのサインアップ
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (response.session != null && response.user != null) {
          final userId = response.user!.id;

          // 'users'テーブルにユーザー情報を挿入
          await Supabase.instance.client.from('users').insert({
            'id': userId,
            'email': email,
            'name': name,
          });

          // ログイン成功メッセージ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('サインアップに成功しました！')),
          );

          // ホーム画面に遷移し、ナビゲーションスタックをクリア
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
        }
      } catch (e) {
        // エラーメッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サインアップ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'サインアップしてはじめる',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // 名前入力フィールド
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '名前'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '名前を入力してください';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              // メールアドレス入力フィールド
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'メールアドレス'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'メールアドレスを入力してください';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              // パスワード入力フィールド
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'パスワードを入力してください';
                  } else if (value.length < 6) {
                    return 'パスワードは6文字以上で入力してください';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // サインアップボタン
              ElevatedButton(
                onPressed: _signup,
                child: Text('サインアップ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
