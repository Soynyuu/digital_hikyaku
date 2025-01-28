import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../letter_read/received_letters.dart';
import '../letter_write/write_top.dart';
import '../walk_history/walk.dart';
import '../contacts/contacts.dart';
import '../bottombar.dart'; // 追加: BottomBarをインポート

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildMenuCard(
      BuildContext context, String title, IconData icon, int tabIndex) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white.withOpacity(0.9),
      child: InkWell(
        onTap: () {
          BottomBar.globalKey.currentState?.selectTab(tabIndex);
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.brown,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.sawarabiMincho(
                  fontSize: 18,
                  color: Colors.brown[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Image.asset(
            'assets/digital_hikyaku_logo.png',
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            children: [
              _buildMenuCard(
                context,
                '手紙を読む',
                Icons.mail,
                1,
              ),
              _buildMenuCard(
                context,
                '手紙を書く',
                Icons.edit,
                2,
              ),
              _buildMenuCard(
                context,
                '歩数履歴',
                Icons.directions_walk,
                3,
              ),
              _buildMenuCard(
                context,
                '連絡先',
                Icons.people,
                4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
