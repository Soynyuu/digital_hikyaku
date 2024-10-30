//とりあえず機能は実装せず、ハリボテで
import 'package:flutter/material.dart';

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> addressBook = [
      {'name': '山田 太郎'},
      {'name': '鈴木 次郎'},
      {'name': '佐藤 花子'},
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
          );
        },
      ),
    );
  }
}
