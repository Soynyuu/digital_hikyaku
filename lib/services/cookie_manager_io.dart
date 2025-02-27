import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// 永続的なクッキージャーのインスタンス
PersistCookieJar? _cookieJar;

/// モバイルプラットフォーム用のクッキーマネージャーを作成
///
/// iOS/Android でクッキーを永続化して管理するための Dio インターセプターを返します
Future<PersistCookieJar> _getCookieJar() async {
  if (_cookieJar != null) {
    return _cookieJar!;
  }

  // アプリのドキュメントディレクトリを取得
  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;

  // クッキーを保存するディレクトリを作成
  final cookiePath = '$appDocPath/.cookies/';
  await Directory(cookiePath).create(recursive: true);

  // 永続的なクッキージャーを作成
  _cookieJar = PersistCookieJar(
    storage: FileStorage(cookiePath),
    ignoreExpires: false,
  );

  return _cookieJar!;
}

/// モバイルプラットフォーム用のクッキーマネージャーを作成して返す
Interceptor createCookieManager() {
  return _AsyncCookieManager();
}

/// クッキーを非同期で初期化するためのカスタムインターセプター
class _AsyncCookieManager extends Interceptor {
  CookieManager? _cookieManager;
  bool _initializing = false;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (_cookieManager == null && !_initializing) {
        _initializing = true;
        final cookieJar = await _getCookieJar();
        _cookieManager = CookieManager(cookieJar);
        _initializing = false;
      }

      if (_cookieManager != null) {
        // クッキーマネージャーが初期化されていればリクエストを処理
        _cookieManager!.onRequest(options, handler);
      } else {
        // 初期化中なら少し待ってからリトライ
        await Future.delayed(const Duration(milliseconds: 50));
        onRequest(options, handler);
      }
    } catch (e) {
      debugPrint('Cookie manager error: $e');
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_cookieManager != null) {
      _cookieManager!.onResponse(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_cookieManager != null) {
      _cookieManager!.onError(err, handler);
    } else {
      handler.next(err);
    }
  }
}

/// すべてのクッキーをクリアする
Future<void> clearAllCookies() async {
  try {
    final cookieJar = await _getCookieJar();
    await cookieJar.deleteAll();
    debugPrint('All cookies cleared');
  } catch (e) {
    debugPrint('Error clearing cookies: $e');
  }
}
