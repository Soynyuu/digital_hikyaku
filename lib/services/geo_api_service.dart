import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoApiService {
  static const String baseUrl =
      'https://geoapi.heartrails.com/api/json?method=searchByPostal';

  Future<http.Response> getGeoLocation(String zipCode) async {
    return await http.get(
      Uri.parse('$baseUrl?zipcode=$zipCode'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<List<ZipCodeResult>> searchZipCode(String zipCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl&postal=$zipCode'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response'] != null && data['response']['location'] != null) {
        var locations = data['response']['location'];
        if (locations is! List) {
          locations = [locations];
        }
        return locations.map((item) => ZipCodeResult.fromJson(item)).toList();
      } else {
        throw Exception('郵便番号に該当する住所が見つかりませんでした。');
      }
    } else {
      throw Exception('サーバーエラー: ${response.statusCode}');
    }
  }
}

class ZipCodeResult {
  final String postal;
  final String prefecture;
  final String city;
  final String cityKana;
  final String town;
  final String townKana;
  final double x; // 経度
  final double y; // 緯度

  ZipCodeResult({
    required this.postal,
    required this.prefecture,
    required this.city,
    required this.cityKana,
    required this.town,
    required this.townKana,
    required this.x,
    required this.y,
  });

  factory ZipCodeResult.fromJson(Map<String, dynamic> json) {
    return ZipCodeResult(
      postal: json['postal'],
      prefecture: json['prefecture'],
      city: json['city'] ?? '',
      cityKana: json['city-kana'] ?? '',
      town: json['town'] ?? '',
      townKana: json['town-kana'] ?? '',
      x: double.parse(json['x']),
      y: double.parse(json['y']),
    );
  }
}
