import 'dart:convert';
import 'package:get/get.dart';
import 'package:journal/data/models/journal_entry.dart';
import 'package:journal/data/repositories/journal_repository.dart';
import 'package:journal/data/services/encryption_service.dart';

class SecureJournalRepository {
  final JournalRepository _repository = Get.find<JournalRepository>();
  final EncryptionService _encryptionService = Get.find<EncryptionService>();

  bool get isEncryptionEnabled => true;

  // Secure versions of repository methods
  Future<int> createEntry(JournalEntry entry) async {
    if (isEncryptionEnabled) {
      final secureEntry = await _encryptEntry(entry);
      return await _repository.createEntry(secureEntry);
    } else {
      return await _repository.createEntry(entry);
    }
  }

  Future<int> updateEntry(JournalEntry entry) async {
    if (isEncryptionEnabled) {
      final secureEntry = await _encryptEntry(entry);
      return await _repository.updateEntry(secureEntry);
    } else {
      return await _repository.updateEntry(entry);
    }
  }

  Future<int> deleteEntry(int id) async {
    return await _repository.deleteEntry(id);
  }

  Future<JournalEntry?> getEntry(int id) async {
    final entry = await _repository.getEntry(id);
    if (entry == null) return null;

    if (isEncryptionEnabled) {
      return await _decryptEntry(entry);
    } else {
      return entry;
    }
  }

  Future<List<JournalEntry>> getAllEntries() async {
    final entries = await _repository.getAllEntries();

    if (isEncryptionEnabled) {
      final decryptedEntries = <JournalEntry>[];
      for (final entry in entries) {
        decryptedEntries.add(await _decryptEntry(entry));
      }
      return decryptedEntries;
    } else {
      return entries;
    }
  }

  Future<List<JournalEntry>> getEntriesByDate(DateTime date) async {
    final entries = await _repository.getEntriesByDate(date);

    if (isEncryptionEnabled) {
      final decryptedEntries = <JournalEntry>[];
      for (final entry in entries) {
        decryptedEntries.add(await _decryptEntry(entry));
      }
      return decryptedEntries;
    } else {
      return entries;
    }
  }

  // Helper methods for encryption/decryption
  Future<JournalEntry> _encryptEntry(JournalEntry entry) async {
    // Encrypt sensitive fields
    final encryptedContent = await _encryptionService.encrypt(entry.content);
    final encryptedTitle = await _encryptionService.encrypt(entry.title);

    // Create a metadata map for other fields
    final metadata = {'mood': entry.mood, 'tags': entry.tags, 'imageUrl': entry.imageUrl};
    final encryptedMetadata = await _encryptionService.encrypt(jsonEncode(metadata));

    // Return an entry with encrypted data
    return entry.copyWith(
      title: encryptedTitle,
      content: encryptedContent,
      // Store metadata in the mood field (which will be overwritten upon decryption)
      mood: encryptedMetadata,
      // Clear other fields that are now in metadata
      tags: null,
      imageUrl: null,
    );
  }

  Future<JournalEntry> _decryptEntry(JournalEntry entry) async {
    // Decrypt sensitive fields
    final decryptedContent = await _encryptionService.decrypt(entry.content);
    final decryptedTitle = await _encryptionService.decrypt(entry.title);

    // Decrypt and parse metadata
    Map<String, dynamic> metadata = {};
    if (entry.mood != null) {
      try {
        final decryptedMetadata = await _encryptionService.decrypt(entry.mood!);
        metadata = jsonDecode(decryptedMetadata) as Map<String, dynamic>;
      } catch (e) {
        // If decryption fails, the entry might be from before encryption was implemented
        // Just use the mood field as-is
        metadata = {'mood': entry.mood};
      }
    }

    // Return an entry with decrypted data
    return entry.copyWith(
      title: decryptedTitle,
      content: decryptedContent,
      mood: metadata['mood'] as String?,
      tags: metadata['tags'] != null ? List<String>.from(metadata['tags']) : null,
      imageUrl: metadata['imageUrl'] as String?,
    );
  }
}
