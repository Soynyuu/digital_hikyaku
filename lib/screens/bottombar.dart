import 'package:flutter/material.dart';
import 'contacts/contacts.dart';
import 'home/home.dart';
import 'letter_write/write_top.dart';
import 'walk_history/walk.dart';
import '../widgets/background_scaffold.dart';
import 'letter_read/received_letters.dart'; // 追加: 受信手紙一覧画面をインポート

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ReceivedLettersScreen(), // 修正: 受信手紙一覧画面を追加
    LetterWriteScreen(),
    WalkHistoryScreen(),
    ContactsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_post_office),
            label: '見る',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'walk_history',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'contacts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
