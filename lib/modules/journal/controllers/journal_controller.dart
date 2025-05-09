import 'package:get/get.dart';
import 'package:journal/data/models/journal_entry.dart';
import 'package:journal/data/repositories/journal_repository.dart';

class JournalController extends GetxController {
  final JournalRepository _repository = JournalRepository();

  final RxList<JournalEntry> entries = <JournalEntry>[].obs;
  final Rx<JournalEntry?> selectedEntry = Rx<JournalEntry?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllEntries();
  }

  Future<void> fetchAllEntries() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      entries.value = await _repository.getAllEntries();
    } catch (e) {
      errorMessage.value = 'Failed to load journal entries: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEntriesByDate(DateTime date) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      entries.value = await _repository.getEntriesByDate(date);
    } catch (e) {
      errorMessage.value = 'Failed to load journal entries: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getEntryById(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      selectedEntry.value = await _repository.getEntry(id);
    } catch (e) {
      errorMessage.value = 'Failed to load journal entry: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createEntry({
    required String title,
    required String content,
    String? imageUrl,
    String? mood,
    List<String>? tags,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final now = DateTime.now();
      final entry = JournalEntry(
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
        imageUrl: imageUrl,
        mood: mood,
        tags: tags,
      );

      final id = await _repository.createEntry(entry);

      if (id > 0) {
        await fetchAllEntries();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to create journal entry: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateEntry({
    required int id,
    required String title,
    required String content,
    String? imageUrl,
    String? mood,
    List<String>? tags,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final entry = await _repository.getEntry(id);

      if (entry == null) {
        errorMessage.value = 'Journal entry not found';
        return false;
      }

      final updatedEntry = entry.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
        imageUrl: imageUrl,
        mood: mood,
        tags: tags,
      );

      final result = await _repository.updateEntry(updatedEntry);

      if (result > 0) {
        await fetchAllEntries();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to update journal entry: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteEntry(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.deleteEntry(id);

      if (result > 0) {
        await fetchAllEntries();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to delete journal entry: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
