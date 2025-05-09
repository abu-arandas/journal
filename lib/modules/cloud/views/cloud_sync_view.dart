import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/modules/cloud/controllers/cloud_sync_controller.dart';

class CloudSyncView extends StatelessWidget {
  final CloudSyncController controller = Get.find<CloudSyncController>();

  CloudSyncView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
      ),
      body: Obx(() => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!controller.isLoggedIn.value) _buildSignInSection(context),
          if (controller.isLoggedIn.value) _buildSyncOptions(context),
          const SizedBox(height: 16),
          _buildSyncStatus(context),
        ],
      ),
    );
  }

  Widget _buildSignInSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign in to enable cloud sync',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showSignInDialog(context);
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                controller.signInAnonymously();
              },
              icon: const Icon(Icons.person_outline),
              label: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOptions(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sync Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto Sync'),
              subtitle: const Text('Automatically sync entries when changes are detected'),
              value: controller.autoSyncEnabled.value,
              onChanged: (value) {
                controller.toggleAutoSync(value);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Sync Now'),
              subtitle: const Text('Manually sync all entries'),
              trailing: const Icon(Icons.sync),
              onTap: () {
                controller.syncAllEntries();
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Sign Out'),
              trailing: const Icon(Icons.logout),
              onTap: () {
                controller.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus(BuildContext context) {
    final status = controller.syncStatus.value;
    final error = controller.syncError.value;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case SyncStatus.idle:
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Ready to sync';
        break;
      case SyncStatus.syncing:
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        statusText = 'Syncing...';
        break;
      case SyncStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Last sync successful';
        break;
      case SyncStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Sync error: $error';
        break;
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isNewAccount = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isNewAccount ? 'Create Account' : 'Sign In'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isNewAccount = !isNewAccount;
                          });
                        },
                        child: Text(
                          isNewAccount 
                              ? 'Already have an account?' 
                              : 'Create new account',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  
                  if (email.isEmpty || password.isEmpty) {
                    Get.snackbar(
                      'Error', 
                      'Please enter email and password',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  
                  if (isNewAccount) {
                    controller.createAccount(email, password);
                  } else {
                    controller.signInWithEmailAndPassword(email, password);
                  }
                  
                  Get.back();
                },
                child: Text(isNewAccount ? 'Create Account' : 'Sign In'),
              ),
            ],
          );
        },
      ),
    );
  }
}
