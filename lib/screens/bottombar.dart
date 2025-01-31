import 'package:flutter/material.dart';
import 'contacts/contacts.dart';
import 'home/home.dart';
import 'letter_write/write_top.dart';
import 'walk_history/walk.dart';
import '../widgets/background_scaffold.dart';
import 'letter_read/received_letters.dart'; // 追加: 受信手紙一覧画面をインポート

class BottomBar extends StatefulWidget {
  final int initialIndex;
  
  const BottomBar({
    super.key,
    this.initialIndex = 0,
  });

  static final GlobalKey<_BottomBarState> globalKey = GlobalKey<_BottomBarState>();

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

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

  void selectTab(int index) {
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_post_office),
            label: '届いた手紙',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu),
            label: '手紙を書く',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: '飛脚履歴',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '連絡先',
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
