class JournalEntry {
  int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String? mood;
  final List<String>? tags;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.mood,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'mood': mood,
      'tags': tags?.join(','),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      imageUrl: map['imageUrl'],
      mood: map['mood'],
      tags: map['tags']?.split(','),
    );
  }

  JournalEntry copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? mood,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
    );
  }
}
