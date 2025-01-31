import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../letter_read/received_letters.dart';
import '../letter_write/write_top.dart';
import '../walk_history/walk.dart';
import '../contacts/contacts.dart';
import '../bottombar.dart';
import '../../widgets/background_scaffold.dart'; // 追加: BackgroundScaffoldをインポート

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToScreen(BuildContext context, int index) {
    // 対応する画面を取得
    Widget screen;
    switch (index) {
      case 1:
        screen = const ReceivedLettersScreen();
        break;
      case 2:
        screen = const LetterWriteScreen();
        break;
      case 3:
        screen = const WalkHistoryScreen();
        break;
      case 4:
        screen = const ContactsScreen();
        break;
      default:
        return;
    }

    // 遷移先の画面をBottomBarで包む
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BottomBar(initialIndex: index),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, String title, IconData icon, int tabIndex) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = MediaQuery.of(context).size.width > 600;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.brown.shade50.withOpacity(0.9),
                Colors.white.withOpacity(0.95),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Colors.white.withOpacity(0.1),
                BlendMode.softLight,
              ),
              child: InkWell(
                onTap: () => _navigateToScreen(context, tabIndex),
                child: Padding(
                  padding: EdgeInsets.all(isWideScreen ? 32 : 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade50.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.brown.shade200.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: isWideScreen ? 44 : 32,
                          color: Colors.brown.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sawarabiMincho(
                          fontSize: isWideScreen ? 20 : 16,
                          color: Colors.brown.shade800,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade50.withOpacity(0.1),
              Colors.white.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center( // 追加: 全体を中央寄せ
            child: SingleChildScrollView(
              child: Container( // 追加: 最大幅を制限するコンテナ
                constraints: const BoxConstraints(
                  maxWidth: 1200, // PC表示時の最大幅を設定
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center, // 追加: 子要素を中央寄せ
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 40),
                        child: Image.asset(
                          'assets/digital_hikyaku_logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWideScreen = constraints.maxWidth > 600;
                            final itemWidth = isWideScreen
                                ? 300.0
                                : (constraints.maxWidth - 48) / 2;
                            return Container( // 追加: グリッドを中央寄せするコンテナ
                              width: isWideScreen
                                  ? 632 // 2列分の幅 (300 * 2 + 32(spacing))
                                  : constraints.maxWidth,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: isWideScreen ? 32 : 16,
                                runSpacing: isWideScreen ? 32 : 16,
                                children: [
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildMenuCard(
                                        context, '手紙を読む', Icons.mail, 1),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildMenuCard(
                                        context, '手紙を書く', Icons.history_edu, 2),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildMenuCard(
                                        context, '歩数履歴', Icons.directions_walk, 3),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildMenuCard(
                                        context, '連絡先', Icons.people, 4),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
