import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.1.26:1080/api'; // サーバーのアドレス

  Future<http.Response> register(
      String name, String displayName, String password) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'display_name': displayName,
        'password': password,
      }),
    );
    return response;
  }

  Future<http.Response> login(String name, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'password': password,
      }),
    );
    return response;
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
    final url = Uri.parse('$baseUrl/letter/receive_history');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  Future<http.Response> readLetter(String letterId) async {
    final url = Uri.parse('$baseUrl/letter/read');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'letter_id': letterId,
      }),
    );
    return response;
  }
}
