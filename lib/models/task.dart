import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final bool isDone;
  final Timestamp timestamp;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.timestamp,
  });
} 