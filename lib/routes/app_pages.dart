import 'package:get/get.dart';
import 'package:journal/modules/auth/views/login_view.dart';
import 'package:journal/modules/home/views/home_view.dart';
import 'package:journal/modules/journal/views/journal_detail_view.dart';
import 'package:journal/modules/journal/views/journal_entry_view.dart';
import 'package:journal/modules/settings/views/settings_view.dart';
import 'package:journal/modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(name: Routes.splash, page: () => const SplashView()),
    GetPage(name: Routes.login, page: () => const LoginView()),
    GetPage(name: Routes.home, page: () => const HomeView()),
    GetPage(name: Routes.journalDetail, page: () => const JournalDetailView()),
    GetPage(name: Routes.journalEntry, page: () => const JournalEntryView()),
    GetPage(name: Routes.settings, page: () => const SettingsView()),
  ];
}
