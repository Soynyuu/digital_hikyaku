import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../widgets/background_scaffold.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> contacts = [];
  List<dynamic> searchResults = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final response = await apiService.getContacts();
      if (response.statusCode == 200) {
        setState(() {
          contacts = jsonDecode(response.body);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('連絡先の読み込みに失敗しました: $e')),
      );
    }
  }

  Future<void> _searchUser(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final response = await apiService.searchUser(query);
      if (response.statusCode == 200) {
        setState(() {
          searchResults = jsonDecode(response.body);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザー検索に失敗しました: $e')),
      );
    }
  }

  Future<void> _addContact(String targetId) async {
    try {
      final response = await apiService.createRelationship(targetId);
      if (response.statusCode == 200) {
        await _loadContacts(); // 連絡先リストを更新
        setState(() {
          searchResults = []; // 検索結果をクリア
          searchController.clear(); // 検索フィールドをクリア
          isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('連絡先を追加しました')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('連絡先の追加に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(
          '住所録',
          style: GoogleFonts.sawarabiMincho(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        // SafeAreaを追加
        child: Padding(
          // Paddingを追加してコンテンツの位置を調整
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8.0), // 上部に少し余白を追加
              TextField(
                controller: searchController,
                onChanged: _searchUser,
                decoration: InputDecoration(
                  labelText: 'ユーザー名で検索',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchUser(searchController.text),
                  ),
                ),
              ),
              Expanded(
                child:
                    isSearching ? _buildSearchResults() : _buildContactsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          title: Text(contact['recipient_display_name'] ?? 'Unknown'),
          subtitle: Text(contact['recipient_name'] ?? ''),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return ListTile(
          title: Text(user['display_name'] ?? 'Unknown'),
          subtitle: Text(user['name'] ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _addContact(user['id']),
          ),
        );
      },
    );
  }
}
