import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? bottomNavigationBar;
  final String? backgroundImage; // 追加

  const BackgroundScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundImage, // 追加
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 変更: 透明から白に変更
      extendBody: true, // 追加
      extendBodyBehindAppBar: true, // 修正: falseからtrueに変更
      appBar: appBar != null
          ? AppBar(
              backgroundColor: Colors.transparent, // 追加
              elevation: 0, // 追加
              title: appBar!.title,
              centerTitle: true,
              // 必要に応じて他のAppBarプロパティも設定
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage ?? 'assets/background.jpg'), // 修正
            fit: BoxFit.cover,
          ),
        ),
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
