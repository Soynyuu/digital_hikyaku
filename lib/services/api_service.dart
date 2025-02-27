import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:digital_hikyaku/services/cookie_service.dart';

class ApiService {
  final String baseUrl;
  final CookieService _cookieService = CookieService();

  ApiService({required this.baseUrl});

  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final url = '$baseUrl/$endpoint';

    if (kIsWeb) {
      // Web用の実装（既存コード）
      return await http.get(Uri.parse(url), headers: headers);
    } else {
      // iOS/Android用の実装（CookieServiceを使用）
      return await _cookieService.makeRequest(
        url,
        method: 'GET',
        headers: headers,
      );
    }
  }

  Future<http.Response> post(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final url = '$baseUrl/$endpoint';

    if (kIsWeb) {
      // Web用の実装（既存コード）
      return await http.post(Uri.parse(url), headers: headers, body: body);
    } else {
      // iOS/Android用の実装（CookieServiceを使用）
      return await _cookieService.makeRequest(
        url,
        method: 'POST',
        headers: headers,
        body: body,
      );
    }
  }

  Future<http.Response> put(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final url = '$baseUrl/$endpoint';

    if (kIsWeb) {
      // Web用の実装（既存コード）
      return await http.put(Uri.parse(url), headers: headers, body: body);
    } else {
      // iOS/Android用の実装（CookieServiceを使用）
      return await _cookieService.makeRequest(
        url,
        method: 'PUT',
        headers: headers,
        body: body,
      );
    }
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final url = '$baseUrl/$endpoint';

    if (kIsWeb) {
      // Web用の実装（既存コード）
      return await http.delete(Uri.parse(url), headers: headers, body: body);
    } else {
      // iOS/Android用の実装（CookieServiceを使用）
      return await _cookieService.makeRequest(
        url,
        method: 'DELETE',
        headers: headers,
        body: body,
      );
    }
  }

  // クッキーをクリアするメソッド
  Future<void> clearCookies() async {
    if (!kIsWeb) {
      await _cookieService.clearCookies();
    }
  }
}
