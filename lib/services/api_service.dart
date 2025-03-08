import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
// CookieServiceのインポートを追加
import 'cookie_service.dart';
// 条件付きインポートはバックアップとして残す
import 'cookie_manager_stub.dart' if (dart.library.io) 'cookie_manager_io.dart';

class ApiService {
  late final Dio _dio;
  bool _isInitialized = false;
  late final CookieService _cookieService;

  ApiService() {
    _cookieService = CookieService();

    _dio = Dio(BaseOptions(
      baseUrl: 'https://backend.digital-hikyaku.com/api',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => true,
      receiveDataWhenStatusError: true,
      followRedirects: true,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.extra['withCredentials'] = true;
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            debugPrint('API Error: ${e.message}');
            return handler.next(e);
          },
        ),
      );

    // 初期化を開始
    initialize();
  }

  // APIサービスの初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 統合されたCookieServiceを使用
      await _cookieService.initialize();
      final cookieManager = await _cookieService.getDioCookieManager();
      _dio.interceptors.add(cookieManager);

      _isInitialized = true;
      debugPrint('APIサービスが初期化されました');
    } catch (e) {
      debugPrint('APIサービス初期化エラー: $e');

      // バックアップ: 従来のクッキー管理方法を試す
      if (!kIsWeb) {
        try {
          final backupCookieManager = await initCookieManager();
          _dio.interceptors.add(backupCookieManager);
          _isInitialized = true;
          debugPrint('バックアップのクッキーマネージャーを使用');
        } catch (e2) {
          debugPrint('バックアップクッキー初期化エラー: $e2');
        }
      }
    }
  }

  // APIリクエスト前に初期化を確認するヘルパーメソッド
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<Response> register(String name, String displayName, String password,
      double userLongitude, double userLatitude) async {
    await _ensureInitialized();
    return await _dio.post(
      '/register',
      data: {
        'name': name,
        'display_name': displayName,
        'password': password,
        'user_longitude': userLongitude, // 数値型のまま送信
        'user_latitude': userLatitude, // 数値型のまま送信
      },
    );
  }

  Future<Response> login(String name, String password) async {
    await _ensureInitialized();
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'name': name,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<Response> logout() async {
    await _ensureInitialized();
    final response = await _dio.post('/logout');
    return response;
  }

  Future<Response> getUserInfo() async {
    await _ensureInitialized();
    final response = await _dio.get('/me');
    return response;
  }

  Future<Response> searchUser(String query) async {
    await _ensureInitialized();
    final url = '/search-user?q=$query';
    final response = await _dio.get(url);
    return response;
  }

  Future<Response> createRelationship(String targetId) async {
    await _ensureInitialized();
    final url = '/relationship/new';
    final response = await _dio.post(
      url,
      data: {
        'target_id': targetId,
      },
    );
    return response;
  }

  Future<Response> createLetter(
    String targetId,
    String content,
    String letterSetId,
  ) async {
    await _ensureInitialized();
    final url = '/letter/new';
    final response = await _dio.post(
      url,
      data: {
        'target_id': targetId,
        'content': content,
        'letter_set_id': letterSetId,
      },
    );
    return response;
  }

  Future<Response> getSendHistory() async {
    await _ensureInitialized();
    final url = '/letter/send_history';
    final response = await _dio.get(url);
    return response;
  }

  Future<Response> getReceiveHistory() async {
    await _ensureInitialized();
    final url = '/letter/receive_history';
    final response = await _dio.get(url);
    return response;
  }

  Future<Response> readLetter(String letterId) async {
    await _ensureInitialized();
    final url = '/letter/read';
    final response = await _dio.post(
      url,
      data: {
        'letter_id': letterId,
      },
    );
    return response;
  }

  Future<Response> getContacts() async {
    await _ensureInitialized();
    final url = '/relationship/list';
    final response = await _dio.get(url);
    return response;
  }

  // クッキーをクリアするメソッド
  Future<void> clearCookies() async {
    await _cookieService.clearCookies();
  }

  // デバッグ用：クッキー情報を表示
  Future<void> printCookies() async {
    await _cookieService.printAllCookies();
  }
}
