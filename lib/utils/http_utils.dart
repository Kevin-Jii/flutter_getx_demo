import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';

import '../config.dart';
import 'my_utils.dart';

class HttpUtils {
  static HttpUtils _instance = HttpUtils._internal();

  factory HttpUtils() => _instance;

  late Dio dio;
  CancelToken cancelToken = CancelToken();

  HttpUtils._internal() {
    // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = BaseOptions(
      // 请求基地址,可以包含子路径
      baseUrl: SERVER_API_URL,

      //连接服务器超时时间，单位是毫秒.
      connectTimeout: Duration(seconds: 30),

      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      // receiveTimeout: Duration(milliseconds: 5000),

      // Http请求头.
      headers: {},
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    // Cookie管理
    CookieJar cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors
        .add(LoggyDioInterceptor(requestHeader: true, requestBody: true));

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      // 在请求被发送之前做一些预处理
      return handler.next(options); // continue
    }, onResponse: (response, handler) {
      // 在返回响应数据之前做一些预处理
      return handler.next(response);
    }, onError: (DioException e, handler) {
      // 当请求失败时做一些预处理
      ErrorEntity eInfo = createErrorEntity(e);
      // 错误提示
      MyUtils.showLoading(loadText: eInfo.message.toString());
      // 错误交互处理
      switch (eInfo.code) {
        case 401: // 没有权限 重新登录
          break;
        default:
      }
      return handler.next(e);
    }));
  }

  /// 读取token
  Map<String, dynamic> getAuthorizationHeader() {
    String? token = null; // 这里你需要根据实际情况获取token
    if (token != null) {
      return {'Authorization': 'JWT $token'};
    } else {
      return {}; // 返回一个空的 Map，而不是 null
    }
  }

  /// restful get 操作
  Future get(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }

    // 确保 params 是 Map<String, dynamic> 类型
    Map<String, dynamic> queryParameters = {};
    if (params != null) {
      if (params is Map<String, dynamic>) {
        queryParameters = params;
      } else {
        // 如果 params 不是 Map<String, dynamic> 类型，可以进行转换或抛出错误
        throw ArgumentError('Params should be of type Map<String, dynamic>');
      }
    }

    var response = await dio.get(path,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken);
    return response.data;
  }

  /// restful post 操作
  Future post(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.post(path,
        data: params, options: requestOptions, cancelToken: cancelToken);
    return response.data;
  }

  /// restful put 操作
  Future put(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.put(path,
        data: params, options: requestOptions, cancelToken: cancelToken);
    return response.data;
  }

  /// restful patch 操作
  Future patch(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }

    var response = await dio.patch(path,
        data: params, options: requestOptions, cancelToken: cancelToken);

    return response.data;
  }

  /// restful delete 操作
  Future delete(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.delete(path,
        data: params, options: requestOptions, cancelToken: cancelToken);
    return response.data;
  }

  /// restful post form 表单提交操作
  Future postForm(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.post(path,
        data: FormData.fromMap(params),
        options: requestOptions,
        cancelToken: cancelToken);
    return response.data;
  }

  /*
   * error统一处理
   */
  ErrorEntity createErrorEntity(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        {
          return ErrorEntity(code: -1, message: "请求取消");
        }
      case DioExceptionType.connectionTimeout:
        {
          return ErrorEntity(code: -1, message: "连接超时");
        }
      case DioExceptionType.sendTimeout:
        {
          return ErrorEntity(code: -1, message: "请求超时");
        }

      case DioExceptionType.receiveTimeout:
        {
          return ErrorEntity(code: -1, message: "响应超时");
        }
      case DioExceptionType.badResponse:
        {
          try {
            int? errCode = error.response?.statusCode;
            if (errCode == null) {
              return ErrorEntity(code: -2, message: error.message);
            }
            switch (errCode) {
              case 400:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "请求语法错误");
                }

              case 401:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "没有权限");
                }

              case 403:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "服务器拒绝执行");
                }
              case 404:
                {
                  return ErrorEntity(code: errCode, message: "无法连接服务器");
                }
              case 405:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "请求方法被禁止");
                }
              case 500:
                {
                  return ErrorEntity(code: errCode, message: "服务器内部错误");
                }
              case 502:
                {
                  return ErrorEntity(code: errCode, message: "无效的请求");
                }
              case 503:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "服务器挂了");
                }
              case 505:
                {
                  return ErrorEntity(
                      code: errCode,
                      message:
                          error.response?.data['message'] ?? "不支持HTTP协议请求");
                }
              default:
                {
                  return ErrorEntity(
                      code: errCode, message: error.response?.data['message']);
                }
            }
          } on Exception catch (_) {
            return ErrorEntity(code: -1, message: "未知错误");
          }
        }
      default:
        {
          return ErrorEntity(code: -1, message: error.message);
        }
    }
  }
}

// 异常处理
class ErrorEntity implements Exception {
  int code;
  String? message;

  ErrorEntity({required this.code, this.message});

  @override
  String toString() {
    if (message == null) return "Exception";
    return "Exception: code $code, $message";
  }
}
