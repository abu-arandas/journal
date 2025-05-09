import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/localization/language_controller.dart';

class LanguageView extends StatelessWidget {
  final LanguageController controller = Get.find<LanguageController>();

  LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('language'.tr)), body: Obx(() => _buildLanguagesList()));
  }

  Widget _buildLanguagesList() {
    return ListView.builder(
      itemCount: controller.availableLanguages.length,
      itemBuilder: (context, index) {
        final language = controller.availableLanguages[index];
        final isSelected =
            controller.languageCode.value == language['languageCode'] &&
            controller.countryCode.value == language['countryCode'];

        return RadioListTile<bool>(
          title: Text(language['name']!),
          value: true,
          groupValue: isSelected,
          onChanged: (_) {
            controller.changeLanguage(language['languageCode']!, language['countryCode']!);
          },
          secondary: _buildLanguageFlag(language['countryCode']!),
        );
      },
    );
  }

  Widget _buildLanguageFlag(String countryCode) {
    // This is a simplified version, ideally you'd use proper flag images
    IconData flagIcon;
    switch (countryCode) {
      case 'US':
        flagIcon = Icons.flag;
        break;
      case 'ES':
        flagIcon = Icons.flag;
        break;
      case 'FR':
        flagIcon = Icons.flag;
        break;
      default:
        flagIcon = Icons.flag;
    }

    return Icon(flagIcon);
  }
}
