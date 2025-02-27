import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

/// クッキー管理を行うサービスクラス
///
/// Webとネイティブアプリでのクッキー管理の違いを吸収します。
/// シングルトンパターンを使用して、アプリ全体で一貫したクッキー管理を提供します。
class CookieService {
  static final CookieService _instance = CookieService._internal();
  late CookieJar _cookieJar;
  late Dio _dio;
  bool _isInitialized = false;

  /// シングルトンインスタンスを返すファクトリコンストラクタ
  factory CookieService() {
    return _instance;
  }

  CookieService._internal();

  /// クッキーサービスの初期化
  ///
  /// プラットフォームに応じた適切なクッキー管理を設定します
  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio();

    if (kIsWeb) {
      // Web用のクッキー管理（ブラウザが自動的に処理）
      _cookieJar = CookieJar();
    } else {
      // iOS/Android用の永続化クッキー
      try {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;
        _cookieJar = PersistCookieJar(
          storage: FileStorage("$appDocPath/.cookies/"),
        );
      } catch (e) {
        print('クッキーストレージの初期化エラー: $e');
        // フォールバックとしてメモリ内クッキージャーを使用
        _cookieJar = CookieJar();
      }
    }

    _dio.interceptors.add(CookieManager(_cookieJar));
    _isInitialized = true;
  }

  /// HTTPリクエストにクッキーを適用して実行
  ///
  /// [url] リクエスト先URL
  /// [method] HTTPメソッド (GET, POST, PUT, DELETE)
  /// [headers] リクエストヘッダー
  /// [body] リクエストボディ
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

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: headers);
          break;
        case 'POST':
          response =
              await http.post(Uri.parse(url), headers: headers, body: body);
          break;
        case 'PUT':
          response =
              await http.put(Uri.parse(url), headers: headers, body: body);
          break;
        case 'DELETE':
          response =
              await http.delete(Uri.parse(url), headers: headers, body: body);
          break;
        default:
          throw Exception('サポートされていないHTTPメソッド: $method');
      }
    } catch (e) {
      throw Exception('ネットワークリクエストエラー: $e');
    }

    // レスポンスからクッキーを保存
    _saveCookiesFromResponse(url, response);

    return response;
  }

  /// レスポンスからクッキーを保存する
  void _saveCookiesFromResponse(String url, http.Response response) async {
    final rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      final List<Cookie> receivedCookies = [];

      for (var cookieStr in rawCookies.split(',')) {
        try {
          receivedCookies.add(Cookie.fromSetCookieValue(cookieStr.trim()));
        } catch (e) {
          print('クッキー解析エラー: $e');
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
  }

  /// 全てのクッキーをクリア
  Future<void> clearCookies() async {
    await initialize();
    await _cookieJar.deleteAll();
  }

  /// 特定のURLに関連するクッキーを取得
  ///
  /// [url] クッキーを取得するURL
  Future<List<Cookie>> getCookiesForUrl(String url) async {
    await initialize();
    return await _cookieJar.loadForRequest(Uri.parse(url));
  }
}
