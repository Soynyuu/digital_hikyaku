import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/login.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // デバッグモードでHTTPSの証明書エラーを無視
  if (kDebugMode) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital_Hikyaku',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme:
            GoogleFonts.sawarabiGothicTextTheme(Theme.of(context).textTheme),
      ),
      home: const LoginScreen(),
    );
  }
}
