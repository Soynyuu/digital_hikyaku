import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';

Interceptor createCookieManager() {
  final cookieJar = CookieJar();
  return CookieManager(cookieJar);
}