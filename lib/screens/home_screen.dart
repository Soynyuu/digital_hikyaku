import 'package:flutter/material.dart';
import 'write_screen.dart';
import 'view_screen.dart';
import 'deliver_screen.dart';
import 'address_book_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    WriteScreen(),
    ViewScreen(),
    DeliverScreen(),
    AddressBookScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottomnav-icons/kaku.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/bottomnav-icons/kaku-tap.png',
              width: 24,
              height: 24,
            ),
            label: '書く',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottomnav-icons/miru.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/bottomnav-icons/miru_tap.png',
              width: 24,
              height: 24,
            ),
            label: '見る',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottomnav-icons/todokeru.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/bottomnav-icons/todokeru-tap.png',
              width: 24,
              height: 24,
            ),
            label: 'とどける',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottomnav-icons/jyuusyo.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/bottomnav-icons/jyuusyo_tap.png',
              width: 24,
              height: 24,
            ),
            label: '住所録',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
