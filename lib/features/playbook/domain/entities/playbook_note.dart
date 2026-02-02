class PlaybookNote {
  final String id;
  final String title;
  final String content;
  final String? category;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlaybookNote({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  PlaybookNote copyWith({
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return PlaybookNote(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
