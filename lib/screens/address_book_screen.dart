import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({Key? key}) : super(key: key);

  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _addressBook = [];

  @override
  void initState() {
    super.initState();
    _fetchAddressBook();
  }

  Future<void> _fetchAddressBook() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です。')),
      );
      return;
    }

    try {
      final response = await _supabase
          .from('user_connections')
          .select(
              'connected_user_id, connected_user:users!user_connections_connected_user_id_fkey(name, email)')
          .eq('user_id', userId);

      print('Response: $response'); // デバッグ用にレスポンスを出力

      setState(() {
        _addressBook = response;
      });
    } catch (error) {
      print('Error: $error'); // デバッグ用にエラーを出力
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アドレス帳の取得に失敗しました。')),
      );
    }
  }

  Future<void> _removeUserFromAddressBook(String connectedUserId) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です。')),
      );
      return;
    }

    try {
      await _supabase
          .from('user_connections')
          .delete()
          .match({'user_id': userId, 'connected_user_id': connectedUserId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アドレス帳から削除しました。')),
      );
      _fetchAddressBook();
    } catch (error) {
      print('Error: $error'); // デバッグ用にエラーを出力
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アドレス帳からの削除に失敗しました。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('住所録'),
      ),
      body: _addressBook.isEmpty
          ? Center(child: Text('アドレス帳にユーザーがいません。追加してください。'))
          : ListView.builder(
              itemCount: _addressBook.length,
              itemBuilder: (context, index) {
                final connectedUser = _addressBook[index]['connected_user'];
                return ListTile(
                  title: Text(connectedUser['name']),
                  subtitle: Text(connectedUser['email']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeUserFromAddressBook(
                        _addressBook[index]['connected_user_id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContactScreen()),
          ).then((_) {
            _fetchAddressBook(); // 追加後にアドレス帳を再取得
          });
        },
        child: Icon(Icons.add),
        tooltip: '新しく追加',
      ),
    );
  }
}

class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers(String query) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です。')),
      );
      return;
    }

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabase
          .from('users')
          .select('id, name, email')
          .ilike('name', '%$query%')
          .neq('id', userId);

      setState(() {
        _searchResults = response;
        _isLoading = false;
      });
    } catch (error) {
      print('Error: $error'); // デバッグ用にエラーを出力
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザーの検索に失敗しました。')),
      );
    }
  }

  Future<void> _addUserToAddressBook(String connectedUserId) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です。')),
      );
      return;
    }

    try {
      await _supabase.from('user_connections').insert({
        'user_id': userId,
        'connected_user_id': connectedUserId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アドレス帳に追加しました。')),
      );
      Navigator.pop(context); // 追加後に前の画面に戻る
    } catch (error) {
      print('Error: $error'); // デバッグ用にエラーを出力
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アドレス帳への追加に失敗しました。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ユーザーを追加'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 検索バー
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'ユーザーを検索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _searchUsers,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: _searchResults.isEmpty
                          ? Center(child: Text('検索結果がありません。'))
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final user = _searchResults[index];
                                return ListTile(
                                  title: Text(user['name']),
                                  subtitle: Text(user['email']),
                                  trailing: IconButton(
                                    icon: Icon(Icons.person_add),
                                    onPressed: () =>
                                        _addUserToAddressBook(user['id']),
                                  ),
                                );
                              },
                            ),
                    ),
            ],
          ),
        ));
  }
}
