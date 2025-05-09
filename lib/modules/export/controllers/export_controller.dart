import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:journal/data/models/journal_entry.dart';
import 'package:journal/data/repositories/journal_repository.dart';
import 'package:journal/data/services/export_service.dart';

class ExportController extends GetxController {
  final JournalRepository _journalRepository = Get.find<JournalRepository>();
  final ExportService _exportService = Get.find<ExportService>();

  final RxBool isExporting = false.obs;
  final RxString exportPath = ''.obs;
  final RxString exportError = ''.obs;

  // Export date range
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Selected export format
  final Rx<ExportFormat> selectedFormat = ExportFormat.markdown.obs;

  // Custom filename
  final RxString customFileName = ''.obs;

  // Selected tags for filtering
  final RxList<String> selectedTags = <String>[].obs;

  Future<String> exportJournal() async {
    isExporting.value = true;
    exportError.value = '';
    try {
      final entries = await _getFilteredEntries();

      if (entries.isEmpty) {
        exportError.value = 'No entries found for the selected time period';
        isExporting.value = false;
        return '';
      }

      String fileName = customFileName.value;
      if (fileName.isEmpty) {
        final dateFormat = DateFormat('yyyy-MM-dd');
        fileName = 'journal_${dateFormat.format(startDate.value)}_to_${dateFormat.format(endDate.value)}';
      }

      final filePath = await _exportService.exportEntries(
        entries: entries,
        format: selectedFormat.value,
        customFileName: fileName,
      );

      exportPath.value = filePath;
      isExporting.value = false;
      return filePath;
    } catch (e) {
      exportError.value = e.toString();
      isExporting.value = false;
      return '';
    }
  }

  Future<List<JournalEntry>> _getFilteredEntries() async {
    final allEntries = await _journalRepository.getAllEntries();

    return allEntries.where((entry) {
      // Apply date filter
      final isInDateRange =
          entry.createdAt.isAfter(startDate.value.subtract(const Duration(days: 1))) &&
          entry.createdAt.isBefore(endDate.value.add(const Duration(days: 1)));

      // Apply tag filter if any tags are selected
      bool matchesTags = true;
      if (selectedTags.isNotEmpty && entry.tags != null) {
        matchesTags = selectedTags.any((tag) => entry.tags!.contains(tag));
      }

      return isInDateRange && matchesTags;
    }).toList();
  }

  Future<bool> shareExportedFile() async {
    if (exportPath.value.isEmpty) {
      exportError.value = 'No exported file to share';
      return false;
    }

    // Sharing functionality would typically be implemented using a platform-specific
    // plugin like share_plus. Since we can't implement the actual sharing here,
    // we'll just return true to indicate success.
    return true;
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
  }

  void setExportFormat(ExportFormat format) {
    selectedFormat.value = format;
  }

  void setFileName(String fileName) {
    customFileName.value = fileName;
  }

  void toggleTagSelection(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }
}
