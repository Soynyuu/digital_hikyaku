import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'text_editor_screen.dart'; // テキストエディタ画面のインポート

class SelectRecipientScreen extends StatefulWidget {
  @override
  _SelectRecipientScreenState createState() => _SelectRecipientScreenState();
}

class _SelectRecipientScreenState extends State<SelectRecipientScreen> {
  String? _selectedRecipientId;
  String? _selectedRecipientName;
  List<Map<String, dynamic>> _recipients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipients();
  }

  Future<void> _fetchRecipients() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です。')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user_connections')
          .select(
              'connected_user_id, connected_user:users!user_connections_connected_user_id_fkey(name)')
          .eq('user_id', userId);

      setState(() {
        _recipients = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (error) {
      print('Error: $error'); // デバッグ用にエラーを出力
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('連絡先の取得に失敗しました。')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('宛先選択'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Stack(
                children: <Widget>[
                  Image.asset(
                    'assets/icons/select.png',
                    width: 300,
                    height: 300,
                  ),
                  Positioned(
                    top: 100, // ドロップダウンの位置調整
                    left: 50,
                    right: 50,
                    child: DropdownButton<String>(
                      isExpanded: true, // ドロップダウンを横幅いっぱいに広げる
                      value: _selectedRecipientId,
                      hint: Text('宛先を選択'),
                      items: _recipients.map((recipient) {
                        return DropdownMenuItem<String>(
                          value: recipient['connected_user_id'],
                          child: Text(recipient['connected_user']['name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRecipientId = newValue;
                          _selectedRecipientName = _recipients.firstWhere(
                            (recipient) =>
                                recipient['connected_user_id'] == newValue,
                          )['connected_user']['name'];
                        });
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10, // 画像の下からの距離
                    right: 10, // 画像の右からの距離
                    child: InkWell(
                      onTap: () {
                        if (_selectedRecipientId != null &&
                            _selectedRecipientName != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TextEditorScreen(
                                recipientId: _selectedRecipientId!,
                                recipientName: _selectedRecipientName!,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('宛先を選択してください。'),
                            ),
                          );
                        }
                      },
                      child: Image.asset(
                        'assets/icons/kaku.png',
                        width: 100, // ボタンのサイズを調整
                        height: 100,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
