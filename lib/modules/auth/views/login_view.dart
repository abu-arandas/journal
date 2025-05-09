import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/modules/auth/controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _pinController = TextEditingController();
  final List<String> _enteredPin = [];
  final int _pinLength = 4;

  @override
  void initState() {
    super.initState();

    // Try biometric authentication automatically if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authController.isBiometricEnabled.value) {
        _authController.authenticateWithBiometrics(context);
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _addDigitToPin(String digit) {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin.add(digit);
      });

      if (_enteredPin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _removeDigitFromPin() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
      });
    }
  }

  void _verifyPin() {
    final pin = _enteredPin.join();
    _authController.authenticateWithPin(pin);

    // Clear pin after verification attempt
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _enteredPin.clear();
      });
    });
  }

  void _authenticateWithBiometrics() {
    _authController.authenticateWithBiometrics(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Spacer(),
              Icon(Icons.lock_rounded, size: 60, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text('Enter PIN', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              // PIN display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pinLength,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Error message
              Obx(
                () =>
                    _authController.errorMessage.value.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            _authController.errorMessage.value,
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                          ),
                        )
                        : SizedBox.shrink(),
              ),
              // Numpad
              Expanded(
                flex: 4,
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  children: [
                    for (int i = 1; i <= 9; i++) _buildDigitButton(i.toString()),
                    // Bottom row
                    Obx(
                      () =>
                          _authController.isBiometricEnabled.value
                              ? IconButton(
                                icon: Icon(Icons.fingerprint),
                                onPressed: _authenticateWithBiometrics,
                                iconSize: 40,
                                color: Theme.of(context).colorScheme.primary,
                              )
                              : SizedBox.shrink(),
                    ),
                    _buildDigitButton('0'),
                    IconButton(
                      icon: Icon(Icons.backspace_outlined),
                      onPressed: _removeDigitFromPin,
                      iconSize: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              Spacer(),
              // Forgot PIN button
              TextButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text('Reset Authentication'),
                      content: Text(
                        'If you forgot your PIN, you will need to reset the authentication settings. This will remove PIN and biometric authentication.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            _authController.resetAuthentication();
                          },
                          child: Text('Reset'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Forgot PIN?'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitButton(String digit) {
    return TextButton(
      onPressed: () => _addDigitToPin(digit),
      child: Text(digit, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400)),
    );
  }
}
