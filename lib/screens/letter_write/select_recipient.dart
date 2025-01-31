import 'dart:convert';
import 'package:flutter/material.dart';
import '../../widgets/background_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'select_letterset.dart';
import '../../services/api_service.dart';

class SelectRecipientScreen extends StatefulWidget {
  const SelectRecipientScreen({super.key});

  @override
  _SelectRecipientScreenState createState() => _SelectRecipientScreenState();
}

class _SelectRecipientScreenState extends State<SelectRecipientScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> contacts = [];
  String? selectedRecipient;

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
          contacts = jsonDecode(response.data); // 修正
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('連絡先の読み込みに失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '宛先を選ぶ',
          style: GoogleFonts.sawarabiMincho(
            color: Color(0xff3C2100),
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.brown, width: 1.0),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRecipient,
                    hint: Text(
                      '送り先を選択',
                      style: GoogleFonts.sawarabiMincho(fontSize: 20),
                    ),
                    items: contacts.map<DropdownMenuItem<String>>((contact) {
                      return DropdownMenuItem<String>(
                        value: contact['recipient_id'],
                        child: Text(
                          contact['recipient_display_name'] ?? 'Unknown',
                          style: GoogleFonts.sawarabiMincho(fontSize: 20),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRecipient = newValue;
                      });
                    },
                    isExpanded: true,
                    underline: SizedBox(),
                  ),
                ),
              ),
            ),
            if (selectedRecipient != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'さんへ',
                    style: GoogleFonts.sawarabiMincho(
                      color: Colors.brown,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: selectedRecipient != null
                      ? () {
                          final selectedContact = contacts.firstWhere(
                            (contact) => contact['recipient_id'] == selectedRecipient,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectLettersetScreen(
                                recipientId: selectedContact['recipient_id'].toString(),
                                recipientName: selectedContact['recipient_display_name'] ?? 'Unknown',
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    'レターセットを選択へ >',
                    style: GoogleFonts.sawarabiMincho(
                      color: Colors.brown,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}