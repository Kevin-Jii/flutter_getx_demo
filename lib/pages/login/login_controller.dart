import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_getx_template/utils/http_utils.dart';
import 'package:flutter_getx_template/utils/sp_utils.dart';
import 'package:get/get.dart';

import 'login_model.dart'; // 导入模型

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;
  var uuid = ''.obs;
  var isLoading = false.obs;
  var verificationCode = ''.obs;
  var isCodeLoading = false.obs;
  var imageBytes = Rx<Uint8List?>(null);

  @override
  void onReady() {
    super.onReady();
    fetchVerificationCode();
  }

  void setUsername(String value) => username.value = value;
  void setPassword(String value) => password.value = value;
  void setVerificationCode(String value) => verificationCode.value = value;

  void fetchVerificationCode() async {
    isCodeLoading.value = true;
    try {
      var response = await HttpUtils().get('/code');
      if (response is Map<String, dynamic>) {
        if (response.containsKey('img')) {
          var base64String = response['img'] as String;
          print('Base64 String: $base64String');

          // Ensure base64 string prefix is not omitted
          if (!base64String.startsWith('data:image/jpeg;base64,')) {
            base64String = 'data:image/jpeg;base64,' + base64String;
          }

          // Decode Base64 string
          var decodedBytes = base64Decode(base64String.split(',').last);
          print('Decoded Bytes Length: ${decodedBytes.length}');
          imageBytes.value = decodedBytes;
        }

        // Store uuid
        if (response.containsKey('uuid')) {
          uuid.value = response['uuid'] as String;
        } else {
          print('UUID 不存在');
        }
      } else {
        print('验证码数据为空或无效');
      }
    } catch (e) {
      print('获取验证码时发生异常：$e');
    } finally {
      isCodeLoading.value = false;
    }
  }

  void login() async {
    // 数据验证
    if (username.value.isEmpty ||
        password.value.isEmpty ||
        verificationCode.value.isEmpty) {
      Get.snackbar('登录失败', '用户名、密码或验证码不能为空');
      return;
    }

    isLoading.value = true;
    try {
      var response = await HttpUtils().post('/auth/login', params: {
        'username': username.value,
        'password': password.value,
        'code': verificationCode.value,
        'uuid': uuid.value
      });

      if (response is Map<String, dynamic>) {
        if (response['code'] == 200) {
          var userLoginResponse =
              UserLoginResponseModel.fromJson(response['data']);

          // 存储 UserLoginResponseModel
          await SpUtils.putObject(
              'user_login_response', userLoginResponse.toJson());

          // 导航到主页
          Get.offNamed('/home');
        } else {
          Get.snackbar('登录失败', response['msg'] ?? '未知错误');
          fetchVerificationCode(); // 刷新验证码
        }
      } else {
        Get.snackbar('登录失败', '响应数据格式不正确');
        fetchVerificationCode(); // 刷新验证码
      }
    } catch (e) {
      print(e);
      Get.snackbar('登录失败', '登录请求发生异常: $e'); // 显示详细错误
      fetchVerificationCode(); // 刷新验证码
    } finally {
      isLoading.value = false;
    }
  }
}
