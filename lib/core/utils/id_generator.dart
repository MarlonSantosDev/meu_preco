import 'dart:math';

class IdGenerator {
  static String generate() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final result = StringBuffer();

    for (var i = 0; i < 16; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }

    return result.toString();
  }
}
