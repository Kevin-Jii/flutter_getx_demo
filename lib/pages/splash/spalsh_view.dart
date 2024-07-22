import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // 设置背景颜色为蓝色
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlutterLogo(
                  size: 100, // 设置Logo的大小
                  textColor: Colors.white, // 设置Logo的颜色
                ),
                SizedBox(height: 30), // 加一个间距
                Text(
                  'welcome 👏',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10), // 加一个间距
                Text(
                  '我的第一个app',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30), // 加一个间距
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20, // 距离底部的距离
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                '© 2024 Jing kewei. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
