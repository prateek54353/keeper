import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String id;
  String title;
  String content;
  Timestamp timestamp;
  Timestamp lastModified;
  bool isArchived;
  bool isLocked;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.lastModified,
    this.isArchived = false,
    this.isLocked = false,
  });

  // Factory constructor to create a Note from a Firestore DocumentSnapshot
  factory Note.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      lastModified: data['lastModified'] ?? Timestamp.now(),
      isArchived: data['isArchived'] ?? false,
      isLocked: data['isLocked'] ?? false, // Initialize isLocked from data
    );
  }

  // Method to convert a Note object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'lastModified': lastModified,
      'isArchived': isArchived,
      'isLocked': isLocked, // Include isLocked in the map
    };
  }
} 