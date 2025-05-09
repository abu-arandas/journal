import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/modules/auth/controllers/auth_controller.dart';
import 'package:journal/modules/settings/controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Obx(
        () => ListView(
          children: [
            // Appearance Section
            _buildSectionHeader(context, 'Appearance'),

            // Dark Mode
            SwitchListTile(
              title: Text('Dark Mode'),
              value: settingsController.isDarkMode.value,
              onChanged: (value) {
                settingsController.setDarkMode(value);
              },
            ),

            Divider(),

            // Privacy & Security Section
            _buildSectionHeader(context, 'Privacy & Security'),

            // PIN Authentication
            SwitchListTile(
              title: Text('PIN Authentication'),
              subtitle: Text('Require PIN to access the app'),
              value: authController.isAuthRequired.value,
              onChanged: (value) {
                if (value) {
                  _showPinSetupDialog(context, authController);
                } else {
                  authController.resetAuthentication();
                }
              },
            ),

            // Biometric Authentication
            if (authController.isAuthRequired.value && authController.isBiometricAvailable.value)
              SwitchListTile(
                title: Text('Biometric Authentication'),
                subtitle: Text('Use fingerprint or face ID'),
                value: authController.isBiometricEnabled.value,
                onChanged: (value) {
                  authController.setBiometricEnabled(value);
                },
              ),

            // Allow Screenshots
            SwitchListTile(
              title: Text('Allow Screenshots'),
              subtitle: Text('Enable or disable screenshots within the app'),
              value: settingsController.isScreenshotAllowed.value,
              onChanged: (value) {
                settingsController.setScreenshotAllowed(value);
              },
            ),

            Divider(),

            // Reminders Section
            _buildSectionHeader(context, 'Reminders'),

            // Daily Reminder
            SwitchListTile(
              title: Text('Daily Reminder'),
              subtitle: Text('Get notified to write in your journal'),
              value: settingsController.isReminderEnabled.value,
              onChanged: (value) {
                settingsController.setReminderEnabled(value);
              },
            ),

            // Reminder Time
            if (settingsController.isReminderEnabled.value)
              ListTile(
                title: Text('Reminder Time'),
                subtitle: Text(settingsController.reminderTime.value.format(context)),
                trailing: Icon(Icons.chevron_right),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: settingsController.reminderTime.value,
                  );

                  if (pickedTime != null) {
                    settingsController.setReminderTime(pickedTime);
                  }
                },
              ),

            Divider(),

            // Customization Section
            _buildSectionHeader(context, 'Customization'),

            // Mood Options
            ListTile(
              title: Text('Mood Options'),
              subtitle: Text('Customize available mood emojis'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                _showMoodOptionsEditor(context, settingsController);
              },
            ),

            // Default Tags
            ListTile(
              title: Text('Default Tags'),
              subtitle: Text('Manage your activity tags'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                _showTagsEditor(context, settingsController);
              },
            ),

            Divider(),

            // Account Section
            _buildSectionHeader(context, 'Account'),

            // Sign Out
            ListTile(
              title: Text('Sign Out'),
              leading: Icon(Icons.logout),
              onTap: () {
                authController.signOut();
              },
            ),

            // Reset App
            ListTile(
              title: Text('Reset App', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              subtitle: Text('Clear all data and reset settings'),
              leading: Icon(Icons.restore, color: Theme.of(context).colorScheme.error),
              onTap: () {
                _showResetConfirmation(context, settingsController, authController);
              },
            ),

            // About Section
            _buildSectionHeader(context, 'About'),

            // Version
            ListTile(title: Text('Version'), subtitle: Text('1.0.0')),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  void _showPinSetupDialog(BuildContext context, AuthController controller) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              decoration: InputDecoration(labelText: 'Enter PIN', hintText: 'Enter a 4-digit PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              decoration: InputDecoration(labelText: 'Confirm PIN', hintText: 'Re-enter your PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              final pin = pinController.text;
              final confirmPin = confirmPinController.text;

              if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
                Get.snackbar('Invalid PIN', 'Please enter a 4-digit PIN', snackPosition: SnackPosition.BOTTOM);
                return;
              }

              if (pin != confirmPin) {
                Get.snackbar('PIN Mismatch', 'The PINs you entered do not match', snackPosition: SnackPosition.BOTTOM);
                return;
              }

              controller.setupPin(pin);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMoodOptionsEditor(BuildContext context, SettingsController controller) {
    final moods = controller.moodOptions.toList();
    final textController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Mood Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(labelText: 'Add New Emoji', hintText: 'Enter emoji'),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (textController.text.isNotEmpty) {
                        if (!moods.contains(textController.text)) {
                          moods.add(textController.text);
                        }
                        textController.clear();
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Flexible(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return ReorderableListView(
                      shrinkWrap: true,
                      children:
                          moods.map((mood) {
                            return ListTile(
                              key: ValueKey(mood),
                              title: Text(mood, style: TextStyle(fontSize: 24)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    moods.remove(mood);
                                  });
                                },
                              ),
                            );
                          }).toList(),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = moods.removeAt(oldIndex);
                          moods.insert(newIndex, item);
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      controller.moodOptions.value = moods;
                      Get.back();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagsEditor(BuildContext context, SettingsController controller) {
    final tags = controller.defaultTags.toList();
    final textController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Default Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(labelText: 'Add New Tag', hintText: 'Enter tag name'),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (textController.text.isNotEmpty) {
                        if (!tags.contains(textController.text)) {
                          tags.add(textController.text);
                        }
                        textController.clear();
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Flexible(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return ReorderableListView(
                      shrinkWrap: true,
                      children:
                          tags.map((tag) {
                            return ListTile(
                              key: ValueKey(tag),
                              title: Text(tag),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    tags.remove(tag);
                                  });
                                },
                              ),
                            );
                          }).toList(),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = tags.removeAt(oldIndex);
                          tags.insert(newIndex, item);
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      controller.defaultTags.value = tags;
                      Get.back();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(
    BuildContext context,
    SettingsController settingsController,
    AuthController authController,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Reset App'),
        content: Text('This will erase all your journal entries and reset all settings. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              // Reset settings
              settingsController.resetSettings();
              // Reset authentication
              authController.resetAuthentication();
              // TODO: Reset database (clear all entries)

              Get.snackbar(
                'Reset Complete',
                'All data and settings have been reset.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
