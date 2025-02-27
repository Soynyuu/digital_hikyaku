import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// ネイティブプラットフォーム用のクッキーマネージャーを作成
///
/// iOS/Androidプラットフォームでクッキー管理を行うインターセプターを返します
Future<Interceptor> createCookieManager() async {
  CookieJar cookieJar;

  try {
    // 永続化ストレージの設定を試みる
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    cookieJar = PersistCookieJar(
      storage: FileStorage("$appDocPath/.cookies/"),
    );
  } catch (e) {
    // エラーが発生した場合はメモリ内クッキージャーにフォールバック
    print('永続的クッキーストレージの初期化に失敗しました: $e');
    cookieJar = CookieJar();
  }

  return CookieManager(cookieJar);
}
