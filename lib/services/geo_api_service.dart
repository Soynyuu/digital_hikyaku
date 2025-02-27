import 'dart:convert';
import 'package:http/http.dart' as http;

/// 郵便番号から地理情報を取得するためのサービスクラス
///
/// HeartRails Geo APIを利用して、郵便番号から住所や座標情報を取得します。
class GeoApiService {
  /// HeartRails Geo APIのベースURL
  static const String baseUrl = 'https://geoapi.heartrails.com/api/json';

  /// APIエンドポイント
  static const String searchMethod = 'searchByPostal';

  /// 郵便番号から位置情報を取得する
  ///
  /// [zipCode] 検索する郵便番号
  /// 通信エラーや不正な郵便番号の場合は例外をスローします
  Future<http.Response> getGeoLocation(String zipCode) async {
    final uri = Uri.parse('$baseUrl?method=$searchMethod&postal=$zipCode');

    try {
      return await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      throw Exception('ネットワークエラー: $e');
    }
  }

  /// 郵便番号から住所情報をリストとして検索する
  ///
  /// [zipCode] 検索する郵便番号
  /// 該当する住所が見つからない場合や通信エラーの場合は例外をスローします
  Future<List<ZipCodeResult>> searchZipCode(String zipCode) async {
    final uri = Uri.parse('$baseUrl?method=$searchMethod&postal=$zipCode');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] != null && data['response']['location'] != null) {
          var locations = data['response']['location'];
          if (locations is! List) {
            locations = [locations];
          }
          return locations
              .map<ZipCodeResult>((item) => ZipCodeResult.fromJson(item))
              .toList();
        } else {
          throw Exception('郵便番号に該当する住所が見つかりませんでした。');
        }
      } else {
        throw Exception('サーバーエラー: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('検索処理でエラーが発生しました: $e');
    }
  }
}

/// 郵便番号検索の結果を表すクラス
class ZipCodeResult {
  /// 郵便番号
  final String postal;

  /// 都道府県名
  final String prefecture;

  /// 市区町村名
  final String city;

  /// 市区町村名（カナ）
  final String cityKana;

  /// 町域名
  final String town;

  /// 町域名（カナ）
  final String townKana;

  /// 経度
  final double x;

  /// 緯度
  final double y;

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

  /// JSON形式からZipCodeResultオブジェクトを生成するファクトリメソッド
  factory ZipCodeResult.fromJson(Map<String, dynamic> json) {
    return ZipCodeResult(
      postal: json['postal'] ?? '',
      prefecture: json['prefecture'] ?? '',
      city: json['city'] ?? '',
      cityKana: json['city_kana'] ?? json['city-kana'] ?? '',
      town: json['town'] ?? '',
      townKana: json['town_kana'] ?? json['town-kana'] ?? '',
      x: double.tryParse(json['x'].toString()) ?? 0.0,
      y: double.tryParse(json['y'].toString()) ?? 0.0,
    );
  }

  /// デバッグ情報の表示用
  @override
  String toString() {
    return 'ZipCodeResult(postal: $postal, prefecture: $prefecture, city: $city, town: $town)';
  }
}
