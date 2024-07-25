import 'dart:convert'; // For base64Decode
import 'dart:typed_data';

import 'package:get/get.dart';

import '../../utils/http_utils.dart'; // For HttpUtils

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
    isLoading.value = true;
    try {
      var response = await HttpUtils().post('/auth/login', params: {
        'username': username.value,
        'password': password.value,
        'code': verificationCode.value,
        'uuid': uuid.value
      });

      print(response['code']);
      if (response['code'] == 200) {
        print('Response: $response'); // Print the full response

        // 从响应中提取数据
        var data = response['data'];
        var token = data['token'];
        var user = data['user'];
        var userId = user['id'];
        var userName = user['name'];

        // 你可以在这里使用提取的数据，例如保存 token 和用户信息
        print('Token: $token');
        print('User ID: $userId');
        print('User Name: $userName');

        // 成功登录逻辑
        Get.offNamed('/home');
      } else {
        // 登录失败，刷新验证码
        fetchVerificationCode(); // 刷新验证码
      }
    } catch (e) {
      Get.snackbar('登录失败', '登录请求发生异常: $e'); // 显示详细错误
      fetchVerificationCode(); // 刷新验证码
    } finally {
      isLoading.value = false;
    }
  }
}
