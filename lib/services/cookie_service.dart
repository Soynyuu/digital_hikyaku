import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class CookieService {
  static final CookieService _instance = CookieService._internal();
  late CookieJar _cookieJar;
  late Dio _dio;
  bool _isInitialized = false;

  factory CookieService() {
    return _instance;
  }

  CookieService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio();

    if (kIsWeb) {
      // Web用のクッキー管理（ブラウザが自動的に処理）
      _cookieJar = CookieJar();
    } else {
      // iOS/Android用の永続化クッキー
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      _cookieJar = PersistCookieJar(
        storage: FileStorage("$appDocPath/.cookies/"),
      );
    }

    _dio.interceptors.add(CookieManager(_cookieJar));
    _isInitialized = true;
  }

  // HTTPリクエストにクッキーを適用
  Future<http.Response> makeRequest(
    String url, {
    required String method,
    Map<String, String>? headers,
    Object? body,
  }) async {
    await initialize();

    // クッキーを取得
    final cookies = await _cookieJar.loadForRequest(Uri.parse(url));

    // クッキーヘッダーを作成
    final cookieHeader = cookies.isNotEmpty
        ? cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ')
        : '';

    headers ??= {};
    if (cookieHeader.isNotEmpty) {
      headers['cookie'] = cookieHeader;
    }

    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(Uri.parse(url), headers: headers);
        break;
      case 'POST':
        response =
            await http.post(Uri.parse(url), headers: headers, body: body);
        break;
      case 'PUT':
        response = await http.put(Uri.parse(url), headers: headers, body: body);
        break;
      case 'DELETE':
        response =
            await http.delete(Uri.parse(url), headers: headers, body: body);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // レスポンスからクッキーを保存
    final rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      final List<Cookie> receivedCookies = [];

      for (var cookieStr in rawCookies.split(',')) {
        try {
          receivedCookies.add(Cookie.fromSetCookieValue(cookieStr.trim()));
        } catch (e) {
          print('Error parsing cookie: $e');
        }
      }

      if (receivedCookies.isNotEmpty) {
        await _cookieJar.saveFromResponse(
            Uri.parse(url),
            receivedCookies
                .map((cookie) => Cookie(cookie.name, cookie.value)
                  ..domain = cookie.domain
                  ..expires = cookie.expires
                  ..httpOnly = cookie.httpOnly
                  ..path = cookie.path
                  ..secure = cookie.secure)
                .toList());
      }
    }

    return response;
  }

  // クッキーをクリア
  Future<void> clearCookies() async {
    await initialize();
    await _cookieJar.deleteAll();
  }

  // 特定のURLに関連するクッキーを取得
  Future<List<Cookie>> getCookiesForUrl(String url) async {
    await initialize();
    return await _cookieJar.loadForRequest(Uri.parse(url));
  }
}
