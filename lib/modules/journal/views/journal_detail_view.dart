import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:journal/data/models/journal_entry.dart';
import 'package:journal/modules/journal/controllers/journal_controller.dart';
import 'package:journal/routes/app_pages.dart';

class JournalDetailView extends StatelessWidget {
  const JournalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final JournalController journalController = Get.find<JournalController>();
    final JournalEntry entry = journalController.selectedEntry.value!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Journal Entry'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.toNamed(Routes.journalEntry, arguments: entry);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context, journalController, entry);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (journalController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (journalController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(journalController.errorMessage.value),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () => journalController.getEntryById(entry.id!), child: Text('Retry')),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and mood
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(entry.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  if (entry.mood != null) Text(entry.mood!, style: TextStyle(fontSize: 24)),
                ],
              ),
              SizedBox(height: 16),

              // Title
              Text(entry.title, style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8),

              // Last updated
              Text(
                'Last updated: ${DateFormat('MMM d, yyyy, h:mm a').format(entry.updatedAt)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              SizedBox(height: 16),

              // Tags
              if (entry.tags != null && entry.tags!.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      entry.tags!.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                ),
                SizedBox(height: 16),
              ],

              // Image
              if (entry.imageUrl != null) ...[
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: FileImage(File(entry.imageUrl!)), fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Divider
              Divider(),
              SizedBox(height: 16),

              // Content
              Text(entry.content, style: TextStyle(fontSize: 16, height: 1.5)),
              SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, JournalController controller, JournalEntry entry) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteEntry(entry.id!).then((success) {
                if (success) {
                  Get.back(); // Close the detail view
                  Get.snackbar('Success', 'Journal entry deleted successfully', snackPosition: SnackPosition.BOTTOM);
                } else {
                  Get.snackbar(
                    'Error',
                    controller.errorMessage.value,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    colorText: Theme.of(context).colorScheme.onError,
                  );
                }
              });
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
