import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/localization/app_translations.dart';
import 'package:journal/core/localization/language_controller.dart';
import 'package:journal/core/theme/app_theme.dart';
import 'package:journal/data/repositories/journal_repository.dart';
import 'package:journal/data/repositories/secure_journal_repository.dart';
import 'package:journal/data/services/encryption_service.dart';
import 'package:journal/data/services/export_service.dart';
import 'package:journal/data/services/firebase_service.dart';
import 'package:journal/modules/auth/controllers/auth_controller.dart';
import 'package:journal/modules/cloud/controllers/cloud_sync_controller.dart';
import 'package:journal/modules/export/controllers/export_controller.dart';
import 'package:journal/modules/journal/controllers/journal_controller.dart';
import 'package:journal/modules/settings/controllers/settings_controller.dart';
import 'package:journal/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register services
  final encryptionService = Get.put(EncryptionService());
  await encryptionService.initialize();
  
  // Register repositories
  Get.put(JournalRepository());
  Get.put(SecureJournalRepository());
  
  // Register controllers
  Get.put(SettingsController());
  Get.put(AuthController());
  Get.put(JournalController());
  Get.put(LanguageController());
  Get.put(ExportService());
  Get.put(ExportController());
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    // Register Firebase service
    Get.put(FirebaseService());
    // Register Cloud Sync controller
    Get.put(CloudSyncController());
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // App can still function without Firebase
  }
  
  runApp(const JournalApp());
}

class JournalApp extends StatelessWidget {
  const JournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find<LanguageController>();
    final SettingsController settingsController = Get.find<SettingsController>();
    
    // System UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    return Obx(() {
      // Update app theme based on settings
      final themeMode = settingsController.isDarkMode.value 
          ? ThemeMode.dark 
          : ThemeMode.light;
          
      // Control screenshots if needed
      if (!settingsController.isScreenshotAllowed.value) {
        _disableScreenshots();
      } else {
        _enableScreenshots();
      }
          
      return GetMaterialApp(
        title: 'Journal App'.tr,
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        
        // Navigation
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        
        // Localization
        translations: AppTranslations(),
        locale: Locale(languageController.languageCode.value, 
                      languageController.countryCode.value),
        fallbackLocale: const Locale('en', 'US'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('fr', 'FR'),
        ],
        
        // Default transitions
        defaultTransition: Transition.cupertino,
        
        // Error handling
        onUnknownRoute: (settings) {
          return GetPageRoute(
            page: () => Scaffold(
              appBar: AppBar(title: Text('Error'.tr)),
              body: Center(
                child: Text('Page not found'.tr),
              ),
            ),
          );
        },
      );
    });
  }
  
  void _disableScreenshots() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // On Android this may require additional native code
  }
  
  void _enableScreenshots() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
