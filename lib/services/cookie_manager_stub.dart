import 'package:dio/dio.dart';

/// プラットフォーム互換性のためのスタブクラス
///
/// Webプラットフォームで使用されます
class CookieManager extends Interceptor {
  /// スタブコンストラクタ
  CookieManager([dynamic cookieJar]);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Webプラットフォームではブラウザがクッキーを処理
    handler.next(options);
  }
}

/// スタブインターセプターを作成
Interceptor createCookieManager() {
  return Interceptor(); // 何もしないインターセプター
}
