import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Key constants
  static const String _hasPinKey = 'has_pin';
  static const String _pinKey = 'secure_pin';
  static const String _useBiometricsKey = 'use_biometrics';

  // Initialize authentication settings
  Future<void> initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_hasPinKey)) {
      await prefs.setBool(_hasPinKey, false);
      await prefs.setBool(_useBiometricsKey, false);
    }
  }

  // Check if authentication is required
  Future<bool> isAuthRequired() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasPinKey) ?? false;
  }

  // Check if biometric auth is enabled
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useBiometricsKey) ?? false;
  }

  // Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    try {
      if (!await isBiometricAvailable() || !await isBiometricEnabled()) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your journal',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        // Handle specific biometric errors
        return false;
      }
      return false;
    }
  }

  // Save PIN
  Future<void> savePin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasPinKey, true);
  }

  // Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    return storedPin == pin;
  }

  // Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useBiometricsKey, enabled);
  }

  // Reset authentication settings
  Future<void> resetAuth() async {
    await _secureStorage.delete(key: _pinKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasPinKey, false);
    await prefs.setBool(_useBiometricsKey, false);
  }
}
