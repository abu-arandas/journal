import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/data/services/auth_service.dart';
import 'package:journal/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isAuthenticated = false.obs;
  final RxBool isAuthRequired = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isBiometricAvailable = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    isLoading.value = true;

    try {
      await _authService.initAuth();
      isAuthRequired.value = await _authService.isAuthRequired();
      isBiometricEnabled.value = await _authService.isBiometricEnabled();
      isBiometricAvailable.value = await _authService.isBiometricAvailable();

      // If no auth is required, user is authenticated by default
      if (!isAuthRequired.value) {
        isAuthenticated.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Failed to check authentication status: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    if (!isBiometricEnabled.value || !isBiometricAvailable.value) {
      return false;
    }

    try {
      isLoading.value = true;
      final result = await _authService.authenticateWithBiometrics(context);

      if (result) {
        isAuthenticated.value = true;
        Get.offAllNamed(Routes.home);
      }

      return result;
    } catch (e) {
      errorMessage.value = 'Biometric authentication failed: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    try {
      isLoading.value = true;
      final result = await _authService.verifyPin(pin);

      if (result) {
        isAuthenticated.value = true;
        Get.offAllNamed(Routes.home);
      } else {
        errorMessage.value = 'Incorrect PIN';
      }

      return result;
    } catch (e) {
      errorMessage.value = 'PIN authentication failed: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setupPin(String pin) async {
    try {
      isLoading.value = true;
      await _authService.savePin(pin);
      isAuthRequired.value = true;
      Get.back();
    } catch (e) {
      errorMessage.value = 'Failed to set up PIN: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      isLoading.value = true;
      await _authService.setBiometricEnabled(enabled);
      isBiometricEnabled.value = enabled;
    } catch (e) {
      errorMessage.value = 'Failed to update biometric settings: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetAuthentication() async {
    try {
      isLoading.value = true;
      await _authService.resetAuth();

      isAuthRequired.value = false;
      isBiometricEnabled.value = false;
      isAuthenticated.value = true; // No auth required after reset

      Get.offAllNamed(Routes.home);
    } catch (e) {
      errorMessage.value = 'Failed to reset authentication: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void signOut() {
    isAuthenticated.value = false;
    Get.offAllNamed(Routes.login);
  }
}
