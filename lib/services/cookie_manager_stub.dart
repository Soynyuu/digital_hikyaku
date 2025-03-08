import 'package:dio/dio.dart';

/// Web プラットフォーム用のスタブ実装
///
/// Web では cookie は自動的にブラウザによって管理されるため、
/// 実際の実装は必要ありません
Interceptor createCookieManager() {
  // Web では何もしないインターセプターを返す
  return InterceptorsWrapper();
}

/// Web プラットフォーム用の非同期クッキーマネージャー初期化（スタブ実装）
Future<Interceptor> initCookieManager() async {
  // Web では何もしないインターセプターを返す
  return InterceptorsWrapper();
}

/// Web プラットフォーム用のクッキークリア機能（スタブ実装）
Future<void> clearAllCookies() async {
  // Web では何もしない
}
