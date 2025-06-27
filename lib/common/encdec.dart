import 'dart:convert';

import 'package:encrypt/encrypt.dart' show Key, Encrypter, Fernet, Encrypted;

// import 'package:begzar/common/utils.dart';
// import 'package:encrypt/encrypt.dart';

class EncDec {
  encryptString(String text) {
    final plainText = text;
    final keyString = 'IYqSJoHyqHmC8K2jbiGqppR25xjNM2wo';
    // print(keyString);
    final key = Key.fromUtf8(keyString);

    final b64key = Key.fromUtf8(base64Url.encode(key.bytes).substring(0, 32));
    // if you need to use the ttl feature, you'll need to use APIs in the algorithm itself
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);

    final encrypted = encrypter.encrypt(plainText);

    return encrypted.base64;
  }

  decryptString(String text) {
    final keyString = 'IYqSJoHyqHmC8K2jbiGqppR25xjNM2wo';
    // print(keyString);
    final key = Key.fromUtf8(keyString);

    final b64key = Key.fromUtf8(base64Url.encode(key.bytes).substring(0, 32));
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);

    final encrypted = Encrypted.fromBase64(text);
    final decrypted = encrypter.decrypt(encrypted);

    return decrypted;
  }
}
