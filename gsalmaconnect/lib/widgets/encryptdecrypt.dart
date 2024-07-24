import 'package:encrypt/encrypt.dart';

class EncryptDecrypt {
  static final iv = IV.fromBase64("AAAAAAAAAAAAAAAAAAAAAA==");
  // final iv = enc.IV.allZerosOfLength(16);
  //AAAAAAAAAAAAAAAAAAAAAA==
  // print(iv.base64);
  // print(IV.fromBase64("AAAAAAAAAAAAAAAAAAAAAA==").base64);

  static String encrypt(String msg) {
    final key = Key.fromUtf8('PmLYNJPczzWt5cwLpMonXuVOTrsfumGD');
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(msg, iv: iv);
    return encrypted.base64;
  }

  static String decrypt(String encryptedText) {
    final key = Key.fromUtf8('PmLYNJPczzWt5cwLpMonXuVOTrsfumGD');
    final encrypter = Encrypter(AES(key));
    final encrypted = Encrypted.fromBase64(encryptedText);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}
