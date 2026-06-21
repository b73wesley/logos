import 'dart:convert';
import 'dart:typed_data';

class ImageConvert {
  // função para converter um Binary em bytes
  static Uint8List binaryToBytes(String base64) {
    // Remove prefix "data:image/..;base64," se existir
    final prefixIndex = base64.indexOf('base64,');
    final cleaned = prefixIndex != -1 ? base64.substring(prefixIndex + 7) : base64;

    // Decodifica para bytes
    try {
      return base64Decode(cleaned);
    } catch (e) {
      // fallback: se não for base64, trate o erro apropriadamente
      rethrow;
    }
  }
}
