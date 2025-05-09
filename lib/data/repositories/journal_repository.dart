import 'package:journal/data/models/journal_entry.dart';
import 'package:journal/data/services/database_service.dart';

class JournalRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<int> createEntry(JournalEntry entry) async {
    return await _databaseService.insertEntry(entry);
  }

  Future<int> updateEntry(JournalEntry entry) async {
    return await _databaseService.updateEntry(entry);
  }

  Future<int> deleteEntry(int id) async {
    return await _databaseService.deleteEntry(id);
  }

  Future<JournalEntry?> getEntry(int id) async {
    return await _databaseService.getEntry(id);
  }

  Future<List<JournalEntry>> getAllEntries() async {
    return await _databaseService.getAllEntries();
  }

  Future<List<JournalEntry>> getEntriesByDate(DateTime date) async {
    return await _databaseService.getEntriesByDate(date);
  }
}
