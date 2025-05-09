import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:journal/data/services/export_service.dart';
import 'package:journal/modules/export/controllers/export_controller.dart';
import 'package:journal/modules/settings/controllers/settings_controller.dart';

class ExportView extends StatelessWidget {
  final ExportController controller = Get.find<ExportController>();
  final SettingsController settingsController = Get.find<SettingsController>();

  ExportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Export Journal')), body: Obx(() => _buildBody(context)));
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeSelector(context),
          const SizedBox(height: 24),
          _buildFormatSelector(context),
          const SizedBox(height: 24),
          _buildTagSelector(context),
          const SizedBox(height: 24),
          _buildFileNameInput(context),
          const SizedBox(height: 32),
          _buildExportButton(context),
          if (controller.isExporting.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (controller.exportError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(controller.exportError.value, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          if (controller.exportPath.value.isNotEmpty) _buildExportResult(context),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('From'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectDate(context, isStart: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(dateFormat.format(controller.startDate.value)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('To'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectDate(context, isStart: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(dateFormat.format(controller.endDate.value)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickDateButton(context, 'Last 7 days', 7),
                _buildQuickDateButton(context, 'Last 30 days', 30),
                _buildQuickDateButton(context, 'All time', 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(BuildContext context, String label, int days) {
    return TextButton(
      onPressed: () {
        final now = DateTime.now();
        if (days == 0) {
          // All time - use a date far in the past
          controller.setDateRange(DateTime(2020, 1, 1), now);
        } else {
          controller.setDateRange(now.subtract(Duration(days: days)), now);
        }
      },
      child: Text(label),
    );
  }

  Widget _buildFormatSelector(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export Format', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFormatOption(context, ExportFormat.markdown, 'Markdown (.md)', 'Best for readability and formatting'),
            _buildFormatOption(context, ExportFormat.json, 'JSON (.json)', 'Best for data backup and importing'),
            _buildFormatOption(context, ExportFormat.plainText, 'Plain Text (.txt)', 'Simple text without formatting'),
            _buildFormatOption(context, ExportFormat.html, 'HTML (.html)', 'Viewable in any web browser'),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(BuildContext context, ExportFormat format, String title, String subtitle) {
    return RadioListTile<ExportFormat>(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: format,
      groupValue: controller.selectedFormat.value,
      onChanged: (value) {
        if (value != null) {
          controller.setExportFormat(value);
        }
      },
    );
  }

  Widget _buildTagSelector(BuildContext context) {
    final availableTags = settingsController.defaultTags;

    if (availableTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by Tags (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Only entries with at least one of these tags will be included', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  availableTags.map((tag) {
                    final isSelected = controller.selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.toggleTagSelection(tag);
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileNameInput(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Custom File Name (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(hintText: 'Leave blank for default name', border: OutlineInputBorder()),
              onChanged: (value) {
                controller.setFileName(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download),
        label: const Text('Export Journal'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        onPressed:
            controller.isExporting.value
                ? null
                : () async {
                  await controller.exportJournal();
                },
      ),
    );
  }

  Widget _buildExportResult(BuildContext context) {
    final fileName = controller.exportPath.value.split('/').last;

    return Card(
      margin: const EdgeInsets.only(top: 24),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export Complete!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('File saved as: $fileName'),
            Text('Location: ${controller.exportPath.value}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('View File'),
                  onPressed: () {
                    // This would normally use a platform-specific method to open the file
                    // For simplicity, we'll just show a snackbar
                    Get.snackbar(
                      'File Viewer',
                      'Opening ${controller.exportPath.value}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: () async {
                    await controller.shareExportedFile();
                    Get.snackbar(
                      'Sharing',
                      'Sharing ${controller.exportPath.value}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final currentDate = isStart ? controller.startDate.value : controller.endDate.value;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      if (isStart) {
        if (pickedDate.isAfter(controller.endDate.value)) {
          controller.endDate.value = pickedDate;
        }
        controller.startDate.value = pickedDate;
      } else {
        if (pickedDate.isBefore(controller.startDate.value)) {
          controller.startDate.value = pickedDate;
        }
        controller.endDate.value = pickedDate;
      }
    }
  }
}
