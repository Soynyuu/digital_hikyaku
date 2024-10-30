import 'package:flutter/material.dart';

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> addressBook = [
      {'name': '山田 太郎', 'address': '東京都新宿区1-1-1'},
      {'name': '鈴木 次郎', 'address': '東京都渋谷区2-2-2'},
      {'name': '佐藤 花子', 'address': '東京都港区3-3-3'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('住所録'),
      ),
      body: ListView.builder(
        itemCount: addressBook.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(addressBook[index]['name']!),
            subtitle: Text(addressBook[index]['address']!),
          );
        },
      ),
    );
  }
}
