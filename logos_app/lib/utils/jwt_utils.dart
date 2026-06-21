import 'dart:convert';

class JwtUtils {
  static Future<bool> isValid(String? token) async {
    if (token == null) return false;

    try {
      final payloadMap = _decode(token);
      final exp = payloadMap['exp'];
      if (exp == null) return false;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
      return DateTime.now().isBefore(expiryDate);
    } catch (_) {
      return false;
    }
  }

  /// Checks if the token still has at least minMinutes of validity
  static Future<bool> hasRemaining(String? token, {int minMinutes = 30}) async {
    if (token == null) return false;

    try {
      final payloadMap = _decode(token);
      final exp = payloadMap['exp'];
      if (exp == null) return false;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
      final diff = expiryDate.difference(DateTime.now());
      return diff.inMinutes >= minMinutes;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic> _decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid token');

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    return json.decode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
  }
}
