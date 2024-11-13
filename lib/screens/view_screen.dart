import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({Key? key}) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です。')),
      );
      return;
    }

    try {
      final response = await _supabase
          .from('letters')
          .select(
              'sender_id, content, created_at, sender:users!letters_sender_id_fkey(name)')
          .eq('recipient_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _messages = response;
        _isLoading = false;
      });
    } catch (error) {
      print('Error: $error'); // デバッグ用にエラーを出力
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メッセージの取得に失敗しました。')),
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
        title: Text('受信メッセージ'),
      ),
      body: Stack(
        children: [
          // 背景画像を設定
          Image.asset(
            'assets/icons/haikei.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _messages.isEmpty
                  ? Center(child: Text('メッセージがありません。'))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['content'],
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '送信者: ${message['sender']['name']}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    message['created_at'],
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
