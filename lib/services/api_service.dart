import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
// 条件付きインポートを追加
import 'cookie_manager_stub.dart' if (dart.library.io) 'cookie_manager_io.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
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
      ..interceptors.addAll([
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
        if (!kIsWeb) createCookieManager(),
      ]);
  }

  Future<Response> register(String name, String displayName, String password,
      double userLongitude, double userLatitude) async {
    return await _dio.post(
      '/register',
      data: {
        'name': name,
        'display_name': displayName,
        'password': password,
        'user_longitude': double.parse(userLongitude.toStringAsFixed(6)),
        'user_latitude': double.parse(userLatitude.toStringAsFixed(6)),
      },
    );
  }

  Future<Response> login(String name, String password) async {
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
    final response = await _dio.post('/logout');
    return response;
  }

  Future<Response> getUserInfo() async {
    final response = await _dio.get('/me');
    return response;
  }

  Future<Response> searchUser(String query) async {
    final url = '/search-user?q=$query';
    final response = await _dio.get(url);
    return response;
  }

  Future<Response> createRelationship(String targetId) async {
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
    final url = '/letter/send_history';
    final response = await _dio.get(url);
    return response;
  }

  Future<Response> getReceiveHistory() async {
    final url = '/letter/receive_history';
    final response = await _dio.get(url);
    return response;
  }

  Future<Response> readLetter(String letterId) async {
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
    final url = '/relationship/list';
    final response = await _dio.get(url);
    return response;
  }
}
