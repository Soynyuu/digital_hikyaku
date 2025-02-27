import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:digital_hikyaku/services/cookie_service.dart';

/// APIとの通信を担当するサービスクラス
///
/// プラットフォームに応じた適切な通信処理とクッキー管理を行います。
class ApiService {
  /// APIのベースURL
  final String baseUrl;

  final CookieService _cookieService = CookieService();

  /// APIサービスのコンストラクタ
  ///
  /// [baseUrl] 通信先のベースURL
  ApiService({required this.baseUrl});

  /// GETリクエストを実行
  ///
  /// [endpoint] APIエンドポイント
  /// [headers] リクエストヘッダー
  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final url = '$baseUrl/$endpoint';

    try {
      if (kIsWeb) {
        // Web用の実装
        return await http.get(Uri.parse(url), headers: headers);
      } else {
        // iOS/Android用の実装
        return await _cookieService.makeRequest(
          url,
          method: 'GET',
          headers: headers,
        );
      }
    } catch (e) {
      throw Exception('GETリクエストエラー: $e');
    }
  }

  /// POSTリクエストを実行
  ///
  /// [endpoint] APIエンドポイント
  /// [headers] リクエストヘッダー
  /// [body] リクエストボディ
  Future<http.Response> post(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final url = '$baseUrl/$endpoint';

    try {
      if (kIsWeb) {
        // Web用の実装
        return await http.post(Uri.parse(url), headers: headers, body: body);
      } else {
        // iOS/Android用の実装
        return await _cookieService.makeRequest(
          url,
          method: 'POST',
          headers: headers,
          body: body,
        );
      }
    } catch (e) {
      throw Exception('POSTリクエストエラー: $e');
    }
  }

  /// PUTリクエストを実行
  ///
  /// [endpoint] APIエンドポイント
  /// [headers] リクエストヘッダー
  /// [body] リクエストボディ
  Future<http.Response> put(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final url = '$baseUrl/$endpoint';

    try {
      if (kIsWeb) {
        // Web用の実装
        return await http.put(Uri.parse(url), headers: headers, body: body);
      } else {
        // iOS/Android用の実装
        return await _cookieService.makeRequest(
          url,
          method: 'PUT',
          headers: headers,
          body: body,
        );
      }
    } catch (e) {
      throw Exception('PUTリクエストエラー: $e');
    }
  }

  /// DELETEリクエストを実行
  ///
  /// [endpoint] APIエンドポイント
  /// [headers] リクエストヘッダー
  /// [body] リクエストボディ
  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final url = '$baseUrl/$endpoint';

    try {
      if (kIsWeb) {
        // Web用の実装
        return await http.delete(Uri.parse(url), headers: headers, body: body);
      } else {
        // iOS/Android用の実装
        return await _cookieService.makeRequest(
          url,
          method: 'DELETE',
          headers: headers,
          body: body,
        );
      }
    } catch (e) {
      throw Exception('DELETEリクエストエラー: $e');
    }
  }

  /// クッキーをクリアするメソッド
  Future<void> clearCookies() async {
    if (!kIsWeb) {
      await _cookieService.clearCookies();
    }
  }

  /// JSONデータを解析するユーティリティメソッド
  ///
  /// [response] HTTPレスポンス
  /// 無効なJSONの場合は例外をスローします
  dynamic parseJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('JSONパースエラー: $e');
    }
  }
}
