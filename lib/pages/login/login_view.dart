import 'dart:ui'; // For BackdropFilter

import 'package:flutter/material.dart';
import 'package:flutter_getx_template/utils/my_utils.dart';
import 'package:get/get.dart';

import '../../view/loading_widget.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double inputWidth = screenWidth * 0.8; // Input width
    double imageWidth = screenWidth * 0.3; // Image width
    double inputHeight = 50.0; // Input height

    return Scaffold(
      body: Stack(
        children: [
          // 渐变背景，从左下角到右上角
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5EE7DF), Color(0xFFB490CA)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400), // Max width
                child: Stack(
                  children: [
                    // 毛玻璃效果
                    Positioned.fill(
                      child: Stack(
                        children: [
                          // 背景渐变
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF008F7A),
                                    Color(0xFFFF8066)
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                borderRadius: BorderRadius.circular(20), // 圆角边框
                              ),
                            ),
                          ),
                          // 毛玻璃效果
                          Positioned.fill(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 21.0, sigmaY: 31.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7), // 半透明背景
                                  borderRadius:
                                      BorderRadius.circular(20), // 圆角边框
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 添加 logo 和标题
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 图标
                          Image.asset(
                            MyUtils.getImage('logo'), // 使用 getImage 方法获取路径
                            width: 50, // 设置 logo 宽度
                            height: 50, // 设置 logo 高度
                          ),
                          SizedBox(width: 10), // 图标和标题之间的间距
                          // 标题
                          Text(
                            '欢迎登录',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 89, 72, 199),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 100), // 上方留白以便于图标和标题显示
                          Container(
                            width: inputWidth,
                            child: TextField(
                              onChanged: controller.setUsername,
                              decoration: InputDecoration(
                                labelText: '用户名',
                                prefixIcon: Icon(Icons.person), // 用户名图标
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: inputWidth,
                            child: TextField(
                              onChanged: controller.setPassword,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: '密码',
                                prefixIcon: Icon(Icons.lock), // 密码图标
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Obx(
                            () => Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  width: inputWidth,
                                  height: inputHeight,
                                  child: TextField(
                                    onChanged: controller.setVerificationCode,
                                    decoration: InputDecoration(
                                      labelText: '验证码',
                                      prefixIcon: Icon(Icons.verified), // 验证码图标
                                      contentPadding: EdgeInsets.only(
                                          right: imageWidth + 10), // 右侧图片留出空间
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.fetchVerificationCode(); // 刷新验证码
                                  },
                                  child: Container(
                                    width: imageWidth,
                                    height: inputHeight,
                                    child: controller.imageBytes.value != null
                                        ? Image.memory(
                                            controller.imageBytes.value!,
                                            fit: BoxFit.cover, // 设置图片填充模式
                                          )
                                        : Center(
                                            child:
                                                CircularProgressIndicator()), // 图片加载前显示的 loading 动画
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: inputWidth,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!controller.isLoading.value) {
                                  controller.login(); // 调用登录方法
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // 圆角按钮
                                ),
                                minimumSize:
                                    Size(inputWidth, inputHeight), // 按钮大小
                              ),
                              child: Text('登 录'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => controller.isLoading.value
                ? Positioned.fill(
                    child: LoadingWidget(), // 显示全屏 loading 组件
                  )
                : SizedBox.shrink(), // 占位符
          ),
          // 版权声明
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                '© 2024 Jing Kewei. All rights reserved.',
                style: TextStyle(
                  color: Colors.white, // 版权文本颜色
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
