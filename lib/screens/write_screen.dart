import 'package:flutter/material.dart';

class WriteScreen extends StatelessWidget {
  const WriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              // ボタンがタップされたときの処理をここに書く
            },
            child: Ink(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/tegami_kaitemiyou.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 200, // 画像の幅を指定
              height: 200, // 画像の高さを指定
            ),
          ),
        ],
      ),
    );
  }
}
