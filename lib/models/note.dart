class Note {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<String> imageUrls;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.imageUrls = const [],
  });
} 