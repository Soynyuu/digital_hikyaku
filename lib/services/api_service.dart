import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final sessionId = response.headers['set-cookie'];
        await prefs.setString('session_id', sessionId ?? '');
      }

      return response;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<http.Response> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
    );

    await prefs.remove('session_id');
    return response;
  }

  Future<http.Response> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
    );

    return response;
  }

  Future<http.Response> searchUser(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final url = Uri.parse('$baseUrl/search-user?q=$query');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
    );
    return response;
  }

  Future<http.Response> createRelationship(String targetId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final url = Uri.parse('$baseUrl/relationship/new');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
      body: jsonEncode({
        'target_id': targetId,
      }),
    );
    return response;
  }

  Future<http.Response> createLetter(String targetId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final url = Uri.parse('$baseUrl/letter/new');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
      body: jsonEncode({
        'target_id': targetId,
        'content': content,
      }),
    );
    return response;
  }

  Future<http.Response> getSendHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final url = Uri.parse('$baseUrl/letter/send_history');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
    );
    return response;
  }

  Future<http.Response> getReceiveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final url = Uri.parse('$baseUrl/letter/receive_history');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
    );
    return response;
  }

  Future<http.Response> readLetter(String letterId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final url = Uri.parse('$baseUrl/letter/read');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
      body: jsonEncode({
        'letter_id': letterId,
      }),
    );
    return response;
  }

  Future<http.Response> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id') ?? '';

    final url = Uri.parse('$baseUrl/contacts');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionId,
      },
    );
    return response;
  }
}
