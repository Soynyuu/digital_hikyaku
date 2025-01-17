import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ベースURLをlocalhostに変更
  static const String baseUrl = 'http://10.0.2.2:1080/api';
  // static const String baseUrl = 'http://127.0.0.1:1080/api';  // alternativeのURL

  Future<http.Response> register(
      String name, String displayName, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'display_name': displayName,
        'password': password,
      }),
    );
  }

  Future<http.Response> login(String name, String password) async {
    try {
      debugPrint('Attempting login for user: $name');
      debugPrint('Login URL: ${Uri.parse('$baseUrl/login')}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'password': password,
        }),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      return response;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<http.Response> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  Future<http.Response> getUserInfo() async {
    final url = Uri.parse('$baseUrl/me');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  Future<http.Response> searchUser(String query) async {
    final url = Uri.parse('$baseUrl/search-user?q=$query');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  Future<http.Response> createRelationship(String targetId) async {
    final url = Uri.parse('$baseUrl/relationship/new');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'target_id': targetId,
      }),
    );
    return response;
  }

  Future<http.Response> createLetter(String targetId, String content) async {
    final url = Uri.parse('$baseUrl/letter/new');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'target_id': targetId,
        'content': content,
      }),
    );
    return response;
  }

  Future<http.Response> getSendHistory() async {
    final url = Uri.parse('$baseUrl/letter/send_history');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  Future<http.Response> getReceiveHistory() async {
    return await http.get(Uri.parse('$baseUrl/letter/receive_history'));
  }

  Future<http.Response> readLetter(String letterId) async {
    return await http.post(
      Uri.parse('$baseUrl/letter/read'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'letter_id': letterId,
      }),
    );
  }

  Future<http.Response> getContacts() async {
    final url = Uri.parse('$baseUrl/contacts');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }
}


