import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      try {
        // ログイン処理
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.session != null && response.user != null) {
          // ログイン成功
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ログインに成功しました！')),
          );
          // ホーム画面に遷移
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          // ログイン失敗
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ログインに失敗しました。メールアドレスとパスワードを確認してください。')),
          );
        }
      } catch (e) {
        // エラー処理
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 必要に応じて背景色を設定
      // backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80.0),
            child: Form(
              key: _formKey,
              child: Column(
                // 中央揃え
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // タイトルテキスト
                  Text(
                    'ログインdigital_hikyaku',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 40),
                  // メールアドレス入力フィールド
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'メールアドレス',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'メールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
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
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40),
                  // ログインボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Text(
                        'ログイン',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // サインアップ画面へのナビゲーション
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text('初めての方はこちら'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
