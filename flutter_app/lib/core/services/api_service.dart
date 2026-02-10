import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// API 服务基类
/// 处理与后端的 HTTP 通信
class ApiService {
  late Dio _dio;
  static ApiService? _instance;
  final _storage = const FlutterSecureStorage();
  static void Function()? _on401;

  /// 对该 host 不校验 SSL（浏览器能访问但 App 报证书错误时可开启）
  String? _insecureSslHost;
  bool _insecureSslHostLoaded = false;

  ApiService._internal() {
    _dio = Dio();
    _initializeDio();
  }

  /// 收到 401 时先清除 cookie，再调用此回调（用于触发路由重定向登录）
  static void setOn401(void Function() callback) {
    _on401 = callback;
  }

  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  /// 是否为本机/内网地址（用于放宽 HTTPS 证书校验，便于本地云阁）
  static bool _isLocalOrPrivateHost(String host) {
    if (host.isEmpty) return false;
    if (host == 'localhost' || host == '127.0.0.1') return true;
    if (host.startsWith('192.168.') || host.startsWith('10.') || host.startsWith('172.')) return true;
    return false;
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

    // 本地/内网或已勾选“信任此云阁证书”时放宽 HTTPS 校验
    final adapter = IOHttpClientAdapter();
    adapter.onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (_isLocalOrPrivateHost(host)) return true;
        if (host == AppConfig.defaultBaseUrlHost) return true; // 默认云阁：浏览器可访问时 App 也放宽校验
        if (_insecureSslHost != null && host == _insecureSslHost) return true;
        return false;
      };
      return client;
    };
    _dio.httpClientAdapter = adapter;

    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!_insecureSslHostLoaded) {
          _insecureSslHostLoaded = true;
          _insecureSslHost = await AppConfig.getInsecureSslHost();
        }
        // 动态获取 baseUrl
        final baseUrl = await AppConfig.getBaseUrl();
        options.baseUrl = baseUrl;

        // 添加 cookie（如果存在）
        final cookie = await _getCookie();
        if (cookie != null) {
          options.headers['Cookie'] = cookie;
        }

        final fullUrl = (baseUrl.endsWith('/') ? baseUrl : '$baseUrl/') + (options.path.startsWith('/') ? options.path.substring(1) : options.path);
        AppLogger.d('请求: ${options.method} $fullUrl');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.d('响应: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await ApiService().clearCookie();
          _on401?.call();
        }
        final uri = error.requestOptions.uri.toString();
        AppLogger.e('请求失败: ${error.type} ${error.message}', error);
        AppLogger.d('失败 URL: $uri');
        return handler.next(error);
      },
    ));
  }

  /// 更新 baseUrl
  Future<void> updateBaseUrl(String url) async {
    await AppConfig.setBaseUrl(url);
    _dio.options.baseUrl = url;
  }

  /// 设置“不校验 SSL”的云阁 host，传 null 表示关闭。用于浏览器可访问但 App 证书校验失败时。
  Future<void> setInsecureSslHost(String? host) async {
    await AppConfig.setInsecureSslHost(host);
    _insecureSslHost = host;
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

  /// 是否有已保存的 cookie（用于启动时判断是否已登录）
  Future<bool> hasCookie() async {
    final c = await _getCookie();
    return c != null && c.isNotEmpty;
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
