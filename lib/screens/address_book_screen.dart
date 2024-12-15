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
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchAddressBook();
  }

  Future<void> _fetchCurrentUser() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です。')),
      );
      return;
    }

    try {
      final response = await _supabase
          .from('users')
          .select('id, name, email')
          .eq('id', userId)
          .single();

      setState(() {
        _currentUser = response;
      });
    } catch (error) {
      print('Error fetching current user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロフィール情報の取得に失敗しました。')),
      );
    }
  }

  Future<void> _fetchAddressBook() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('user_connections')
          .select(
              'connected_user_id, connected_user:users!user_connections_connected_user_id_fkey(name, email)')
          .eq('user_id', userId);

      setState(() {
        _addressBook = response;
      });
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アドレス帳の取得に失敗しました。')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    final nameController = TextEditingController(text: _currentUser!['name']);
    final emailController = TextEditingController(text: _currentUser!['email']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('プロフィール編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '名前',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _supabase.from('users').update({
                  'name': nameController.text,
                  'email': emailController.text,
                }).eq('id', _currentUser!['id']);

                Navigator.pop(context);
                _fetchCurrentUser();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('プロフィールを更新しました')),
                );
              } catch (error) {
                print('Error updating profile: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('プロフィールの更新に失敗しました')),
                );
              }
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
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
      print('Error: $error');
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
      body: Column(
        children: [
          if (_currentUser != null)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(_currentUser!['name'][0].toUpperCase(),
                    style: TextStyle(color: Colors.white)),
              ),
              title: Row(
                children: [
                  Text(
                    _currentUser!['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(自分)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              subtitle: Text(_currentUser!['email']),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _updateProfile,
                tooltip: 'プロフィール編集',
              ),
            ),
          Divider(height: 1),
          Expanded(
            child: _addressBook.isEmpty
                ? Center(child: Text('アドレス帳にユーザーがいません。追加してください。'))
                : ListView.builder(
                    itemCount: _addressBook.length,
                    itemBuilder: (context, index) {
                      final connectedUser =
                          _addressBook[index]['connected_user'];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(connectedUser['name'][0].toUpperCase()),
                        ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContactScreen()),
          ).then((_) {
            _fetchAddressBook();
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
      print('Error: $error');
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
      Navigator.pop(context);
    } catch (error) {
      print('Error: $error');
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
                                leading: CircleAvatar(
                                  child: Text(user['name'][0].toUpperCase()),
                                ),
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
      ),
    );
  }
}
