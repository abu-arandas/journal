import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:journal/data/models/journal_entry.dart';

enum ExportFormat { json, markdown, plainText, pdf, html }

class ExportService {
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd_HH-mm');

  Future<String> exportEntries({
    required List<JournalEntry> entries,
    required ExportFormat format,
    String? customFileName,
  }) async {
    final timestamp = _dateFormatter.format(DateTime.now());
    final fileName = customFileName ?? 'journal_export_$timestamp';

    String content;
    String extension;

    switch (format) {
      case ExportFormat.json:
        content = _generateJsonExport(entries);
        extension = 'json';
        break;
      case ExportFormat.markdown:
        content = _generateMarkdownExport(entries);
        extension = 'md';
        break;
      case ExportFormat.plainText:
        content = _generatePlainTextExport(entries);
        extension = 'txt';
        break;
      case ExportFormat.html:
        content = _generateHtmlExport(entries);
        extension = 'html';
        break;
      case ExportFormat.pdf:
        // PDF generation would require additional packages like pdf or printing
        throw UnimplementedError('PDF export is not yet implemented');
    }

    final filePath = await _writeToFile('$fileName.$extension', content);
    return filePath;
  }

  Future<String> _writeToFile(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  String _generateJsonExport(List<JournalEntry> entries) {
    final jsonList = entries.map((entry) => entry.toMap()).toList();
    return jsonEncode({
      'exportDate': DateTime.now().toIso8601String(),
      'totalEntries': entries.length,
      'entries': jsonList,
    });
  }

  String _generateMarkdownExport(List<JournalEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('# Journal Export');
    buffer.writeln('> Exported on ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now())}');
    buffer.writeln('> Total entries: ${entries.length}');
    buffer.writeln('\n---\n');

    for (final entry in entries) {
      buffer.writeln('## ${entry.title}');
      buffer.writeln('*${DateFormat('EEEE, MMMM d, yyyy').format(entry.createdAt)}*');

      if (entry.mood != null) {
        buffer.writeln('\nMood: ${entry.mood}');
      }

      if (entry.tags != null && entry.tags!.isNotEmpty) {
        buffer.writeln('\nTags: ${entry.tags!.join(', ')}');
      }

      buffer.writeln('\n${entry.content}');

      if (entry.imageUrl != null) {
        buffer.writeln('\n![Journal Image](${entry.imageUrl})');
      }

      buffer.writeln('\n---\n');
    }

    return buffer.toString();
  }

  String _generatePlainTextExport(List<JournalEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('JOURNAL EXPORT');
    buffer.writeln('Exported on ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now())}');
    buffer.writeln('Total entries: ${entries.length}');
    buffer.writeln('\n=================\n');

    for (final entry in entries) {
      buffer.writeln(entry.title.toUpperCase());
      buffer.writeln('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(entry.createdAt)}');

      if (entry.mood != null) {
        buffer.writeln('Mood: ${entry.mood}');
      }

      if (entry.tags != null && entry.tags!.isNotEmpty) {
        buffer.writeln('Tags: ${entry.tags!.join(', ')}');
      }

      buffer.writeln('\n${entry.content}');

      if (entry.imageUrl != null) {
        buffer.writeln('\nImage: ${entry.imageUrl}');
      }

      buffer.writeln('\n=================\n');
    }

    return buffer.toString();
  }

  String _generateHtmlExport(List<JournalEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('  <title>Journal Export</title>');
    buffer.writeln('  <style>');
    buffer.writeln('    body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }');
    buffer.writeln('    .entry { margin-bottom: 40px; border-bottom: 1px solid #ccc; padding-bottom: 20px; }');
    buffer.writeln('    .entry-title { font-size: 24px; margin-bottom: 5px; }');
    buffer.writeln('    .entry-date { color: #666; margin-bottom: 15px; }');
    buffer.writeln('    .entry-metadata { display: flex; gap: 20px; margin-bottom: 15px; font-size: 14px; }');
    buffer.writeln('    .entry-content { line-height: 1.6; }');
    buffer.writeln('    .entry-image { max-width: 100%; margin-top: 15px; }');
    buffer.writeln('    .tags { display: flex; gap: 10px; flex-wrap: wrap; }');
    buffer.writeln('    .tag { background: #f0f0f0; padding: 3px 8px; border-radius: 12px; }');
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <h1>Journal Export</h1>');
    buffer.writeln('  <p>Exported on ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now())}</p>');
    buffer.writeln('  <p>Total entries: ${entries.length}</p>');

    for (final entry in entries) {
      buffer.writeln('  <div class="entry">');
      buffer.writeln('    <h2 class="entry-title">${_escapeHtml(entry.title)}</h2>');
      buffer.writeln('    <div class="entry-date">${DateFormat('EEEE, MMMM d, yyyy').format(entry.createdAt)}</div>');

      buffer.writeln('    <div class="entry-metadata">');
      if (entry.mood != null) {
        buffer.writeln('      <div class="mood">Mood: ${_escapeHtml(entry.mood!)}</div>');
      }

      if (entry.tags != null && entry.tags!.isNotEmpty) {
        buffer.writeln('      <div class="tags">');
        for (final tag in entry.tags!) {
          buffer.writeln('        <span class="tag">${_escapeHtml(tag)}</span>');
        }
        buffer.writeln('      </div>');
      }
      buffer.writeln('    </div>');

      buffer.writeln('    <div class="entry-content">${_escapeHtml(entry.content).replaceAll('\n', '<br>')}</div>');

      if (entry.imageUrl != null) {
        buffer.writeln('    <img class="entry-image" src="${_escapeHtml(entry.imageUrl!)}" alt="Journal image">');
      }

      buffer.writeln('  </div>');
    }

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
}
