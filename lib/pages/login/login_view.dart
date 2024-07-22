import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginView extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double inputWidth = screenWidth * 0.8; // 输入框宽度
    double imageWidth = screenWidth * 0.3; // 图片宽度
    double inputHeight = 50.0; // 输入框的高度

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400), // 设置最大宽度
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: inputWidth,
                    child: TextField(
                      onChanged: controller.setUsername,
                      decoration: InputDecoration(
                        labelText: '用户名',
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
                              contentPadding: EdgeInsets.only(
                                  right: imageWidth + 10), // 为右侧图片留出空间
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.fetchVerificationCode(); // 点击图片时刷新验证码
                          },
                          child: Container(
                            width: imageWidth,
                            height: inputHeight,
                            child: controller.imageBytes.value != null
                                ? Image.memory(
                                    controller.imageBytes.value!,
                                    fit: BoxFit.cover, // 设置适当的适配模式
                                  )
                                : Center(
                                    child:
                                        CircularProgressIndicator()), // 图片加载完成前显示加载指示器
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => Container(
                      width: inputWidth,
                      child: controller.isLoading.value
                          ? CircularProgressIndicator() // 显示登录加载指示器
                          : ElevatedButton(
                              onPressed: () {
                                controller.login(); // 调用登录方法
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // 设置圆角
                                ),
                                minimumSize:
                                    Size(inputWidth, inputHeight), // 设置按钮的大小
                              ),
                              child: Text('登 录'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
