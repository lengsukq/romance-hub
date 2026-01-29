import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// API 服务基类
/// 处理与后端的 HTTP 通信
class ApiService {
  late Dio _dio;
  static ApiService? _instance;
  final _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio();
    _initializeDio();
  }

  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  /// 初始化 Dio 配置
  void _initializeDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 动态获取 baseUrl
        final baseUrl = await AppConfig.getBaseUrl();
        options.baseUrl = baseUrl;
        
        // 添加 cookie（如果存在）
        final cookie = await _getCookie();
        if (cookie != null) {
          options.headers['Cookie'] = cookie;
        }
        
        AppLogger.d('请求: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.d('响应: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.e('错误: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// 更新 baseUrl
  Future<void> updateBaseUrl(String url) async {
    await AppConfig.setBaseUrl(url);
    _dio.options.baseUrl = url;
  }

  /// 获取 Dio 实例
  Dio get dio => _dio;

  /// 获取 cookie（从本地存储）
  Future<String?> _getCookie() async {
    return await _storage.read(key: 'cookie');
  }

  /// 保存 cookie
  Future<void> saveCookie(String cookie) async {
    await _storage.write(key: 'cookie', value: cookie);
  }

  /// 清除 cookie
  Future<void> clearCookie() async {
    await _storage.delete(key: 'cookie');
  }

  /// GET 请求
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// POST 请求
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  /// PUT 请求
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  /// DELETE 请求
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }
}
