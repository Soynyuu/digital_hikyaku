import 'package:flutter/material.dart';
import 'write_screen.dart';
import 'view_screen.dart' as received;
import 'deliver_screen.dart' as deliver;
import 'address_book_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    WriteScreen(),
    received.ViewScreen(),
    deliver.DeliverScreen(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '書く',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: '見る',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'とどける',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
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
