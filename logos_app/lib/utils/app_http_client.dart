import 'dart:convert';
import 'dart:io';
import 'package:logos_app/config/app_config.dart';
import 'package:logos_app/core/app_secure_storage.dart';
import 'package:logos_app/utils/jwt_utils.dart';
import 'package:http/http.dart' as http;

class AppHttpClient {
  static String get _base => AppConfig.baseUrl;

  static Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    if (!url.contains('auth')) await _validateSession();
    return http.post(
      Uri.parse('$_base$url'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer {Session().jwt?.accessToken}',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String url, {Map<String, dynamic>? params}) async {
    if (!url.contains('auth')) await _validateSession();
    if (params != null && params.isNotEmpty) {
      String queryString = Uri(queryParameters: params).query;
      url += '?$queryString';
    }
    return http.get(
      Uri.parse('$_base$url'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer {Session().jwt?.accessToken}',
      },
    );
  }

  static Future<http.Response> put(String url, {Map<String, dynamic>? body}) async {
    if (!url.contains('auth')) await _validateSession();
    return http.put(
      Uri.parse('$_base$url'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer {Session().jwt?.accessToken}',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String url) async {
    if (!url.contains('auth')) await _validateSession();
    return http.delete(
      Uri.parse('$_base$url'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer {Session().jwt?.accessToken}',
      },
    );
  }

  static Future<http.Response> auth({String? url, Map<String, dynamic>? body}) async {
    return http.post(
      Uri.parse('$_base/auth'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );
  }

  /// GET without JWT — for public endpoints
  static Future<http.Response> getPublic(String url) async {
    return http.get(Uri.parse('$_base$url'), headers: {'Content-Type': 'application/json; charset=UTF-8'});
  }

  static Future<void> _validateSession() async {
    throw HttpException('No valid session');
  }
}
