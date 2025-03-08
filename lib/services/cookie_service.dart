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
  CookieJar? _cookieJar;
  Dio? _dio;
  bool _isInitialized = false;

  // 基本ドメイン
  static const String _baseDomain = 'backend.digital-hikyaku.com';

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
        final cookiePath = "$appDocPath/.cookies/";

        // クッキー保存用ディレクトリを確実に作成
        await Directory(cookiePath).create(recursive: true);

        _cookieJar = PersistCookieJar(
          storage: FileStorage(cookiePath),
          ignoreExpires: false, // 有効期限を尊重
        );

        logCookieMessage('永続クッキーストレージを初期化: $cookiePath');
      } catch (e) {
        logCookieMessage('クッキーストレージの初期化エラー: $e');
        // フォールバックとしてメモリ内クッキージャーを使用
        _cookieJar = CookieJar();
      }
    }

    if (_cookieJar != null && _dio != null) {
      _dio!.interceptors.add(CookieManager(_cookieJar!));
      _isInitialized = true;
      logCookieMessage('クッキーサービスが初期化されました');
    }
  }

  /// Dioインスタンスのクッキーマネージャーを取得
  Future<CookieManager> getDioCookieManager() async {
    await initialize();
    return CookieManager(_cookieJar!);
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
    final cookies = await _cookieJar!.loadForRequest(Uri.parse(url));

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
          final cleanCookieStr = cookieStr.trim();
          if (cleanCookieStr.isNotEmpty) {
            final cookie = Cookie.fromSetCookieValue(cleanCookieStr);

            // ドメインが指定されていない場合は基本ドメインを設定
            if (cookie.domain == null || cookie.domain!.isEmpty) {
              final requestUri = Uri.parse(url);
              cookie.domain = requestUri.host;
            }

            // `.` で始まるドメインを処理（リクエストとレスポンスの違いを処理）
            if (cookie.domain != null && cookie.domain!.startsWith('.')) {
              final cleanDomain = cookie.domain!.substring(1);
              cookie.domain = cleanDomain;
            }

            receivedCookies.add(cookie);
            logCookieMessage(
                'クッキーを受信: ${cookie.name}=${cookie.value} (domain=${cookie.domain}, path=${cookie.path})');
          }
        } catch (e) {
          logCookieMessage('クッキー解析エラー: $e, cookie: $cookieStr');
        }
      }

      if (receivedCookies.isNotEmpty) {
        await _cookieJar!.saveFromResponse(
          Uri.parse(url),
          receivedCookies,
        );
        logCookieMessage('${receivedCookies.length}個のクッキーを保存しました');
      }
    }
  }

  /// 全てのクッキーをクリア
  Future<void> clearCookies() async {
    await initialize();
    await _cookieJar!.deleteAll();
    logCookieMessage('全てのクッキーをクリアしました');
  }

  /// 特定のURLに関連するクッキーを取得
  ///
  /// [url] クッキーを取得するURL
  Future<List<Cookie>> getCookiesForUrl(String url) async {
    await initialize();
    final cookies = await _cookieJar!.loadForRequest(Uri.parse(url));
    logCookieMessage('$urlのクッキー数: ${cookies.length}');
    return cookies;
  }

  /// デバッグ用：すべてのクッキーを表示
  Future<void> printAllCookies() async {
    if (kIsWeb) {
      logCookieMessage('Webプラットフォーム: クッキーはブラウザにより管理されています');
      return;
    }

    await initialize();
    final apiUrl = 'https://$_baseDomain/api';
    final cookies = await _cookieJar!.loadForRequest(Uri.parse(apiUrl));

    logCookieMessage('=== クッキー情報 ===');
    if (cookies.isEmpty) {
      logCookieMessage('保存されたクッキーはありません');
    } else {
      for (var cookie in cookies) {
        logCookieMessage(
            '${cookie.name}=${cookie.value} (domain=${cookie.domain}, path=${cookie.path}, httpOnly=${cookie.httpOnly}, secure=${cookie.secure})');
      }
    }
    logCookieMessage('==================');
  }
}

// DioのResponseExtension拡張
extension ResponseExtension on Response {
  /// レスポンスに含まれるクッキーを保存する
  Future<void> saveCookies(String baseUrl) async {
    final cookieService = CookieService();
    await cookieService.initialize();

    // この関数はDioレスポンスからクッキーを保存するための補助関数
    // Dioの内部クッキー処理に任せるため実装は省略
  }
}

// デバッグ出力を簡素化する関数
void logCookieMessage(String message) {
  if (!kIsWeb) {
    print('[CookieService] $message');
  }
}
