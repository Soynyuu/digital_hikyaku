import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? bottomNavigationBar;

  const BackgroundScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 追加
      extendBody: true, // 追加
      extendBodyBehindAppBar: true, // 修正: trueからfalseに変更
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
