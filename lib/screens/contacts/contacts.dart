import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ApiService apiService = ApiService();
  List<String> contacts = ['Contact 1', 'Contact 2']; // ダミーデータ
  List<String> searchResults = ['User 1', 'User 2']; // ダミーデータ
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    // ここで連絡先一覧を取得するAPIを呼び出します
    // ダミーデータを使用
    setState(() {
      contacts = ['Contact 1', 'Contact 2'];
    });
  }

  Future<void> _searchUser(String query) async {
    // ここでユーザー検索APIを呼び出します
    // ダミーデータを使用
    setState(() {
      searchResults = ['User 1', 'User 2'];
    });
  }

  Future<void> _addContact(String targetId) async {
    // ここで連絡先追加APIを呼び出します
    // ダミー処理
    setState(() {
      contacts.add(targetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '住所録',
          style: GoogleFonts.sawarabiMincho(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchUser,
              decoration: InputDecoration(
                labelText: 'ユーザー名で検索',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchUser(searchController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                // 連絡先の表示
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact),
                );
              },
            ),
          ),
          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  return ListTile(
                    title: Text(user),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addContact(user),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
