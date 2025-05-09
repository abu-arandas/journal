import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static const String _keyName = 'journal_encryption_key';
  static const String _ivName = 'journal_encryption_iv';

  late Encrypter _encrypter;
  late IV _iv;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Check if we have existing keys
    String? storedKey = await _secureStorage.read(key: _keyName);
    String? storedIv = await _secureStorage.read(key: _ivName);

    if (storedKey != null && storedIv != null) {
      // Use existing keys
      _setupEncrypterWithStoredKeys(storedKey, storedIv);
    } else {
      // Generate new keys
      await _generateAndStoreNewKeys();
    }

    _isInitialized = true;
  }

  void _setupEncrypterWithStoredKeys(String storedKey, String storedIv) {
    final key = Key(base64Url.decode(storedKey));
    _iv = IV(base64Url.decode(storedIv));
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  }

  Future<void> _generateAndStoreNewKeys() async {
    // Generate a random key
    final key = Key.fromSecureRandom(32); // 256 bits
    _iv = IV.fromSecureRandom(16); // 128 bits

    // Store the keys securely
    await _secureStorage.write(key: _keyName, value: base64Url.encode(key.bytes));
    await _secureStorage.write(key: _ivName, value: base64Url.encode(_iv.bytes));

    // Initialize the encrypter
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  }

  /// Encrypts the given data
  Future<String> encrypt(String data) async {
    if (!_isInitialized) {
      await initialize();
    }

    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts the given data
  Future<String> decrypt(String encryptedData) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }

  /// Generate a hash for the given data (useful for verification)
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify the integrity of data using its hash
  bool verifyHash(String data, String hash) {
    return generateHash(data) == hash;
  }

  /// Generate a secure password
  String generateSecurePassword({int length = 16}) {
    const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
