import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';

class FirestoreService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  FirestoreService({required this.uid}) {
    // Enable offline persistence for this instance
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Reference getters with proper user scoping
  CollectionReference get notes =>
      _db.collection('users').doc(uid).collection('notes');
  
  CollectionReference get tasks =>
      _db.collection('users').doc(uid).collection('tasks');

  // C R E A T E
  Future<void> addNote(String title, String content,
      {List<String> imageUrls = const []}) async {
    try {
      await notes.add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrls': imageUrls,
        'lastModified': FieldValue.serverTimestamp(),
        'userId': uid, // Add user ID for additional security
      });
    } catch (e) {
      rethrow;
    }
  }

  // R E A D
  Stream<QuerySnapshot> getNotesStream({String? sortBy}) {
    try {
      final query = notes.orderBy(sortBy ?? 'lastModified', descending: true);
      return query.snapshots(includeMetadataChanges: true);
    } catch (e) {
      rethrow;
    }
  }

  // U P D A T E
  Future<void> updateNote(String docID, String newTitle, String newContent,
      {List<String> imageUrls = const []}) async {
    try {
      await notes.doc(docID).update({
        'title': newTitle,
        'content': newContent,
        'lastModified': FieldValue.serverTimestamp(),
        'imageUrls': imageUrls,
      });
    } catch (e) {
      rethrow;
    }
  }

  // D E L E T E
  Future<void> deleteNote(String docID) async {
    try {
      await notes.doc(docID).delete();
    } catch (e) {
      rethrow;
    }
  }

  // I M A G E S
  Future<String> uploadImage(File image) async {
    try {
      String fileName = 'users/$uid/images/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadDrawing(Uint8List data) async {
    try {
      String fileName = 'users/$uid/drawings/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putData(data);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // T A S K S

  // C R E A T E
  Future<void> addTask(String title) async {
    try {
      await tasks.add({
        'title': title,
        'isDone': false,
        'timestamp': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
        'userId': uid, // Add user ID for additional security
      });
    } catch (e) {
      rethrow;
    }
  }

  // R E A D
  Stream<QuerySnapshot> getTasksStream() {
    try {
      return tasks
          .orderBy('timestamp', descending: true)
          .snapshots(includeMetadataChanges: true);
    } catch (e) {
      rethrow;
    }
  }

  // U P D A T E
  Future<void> updateTaskStatus(String docID, bool isDone) async {
    try {
      await tasks.doc(docID).update({
        'isDone': isDone,
        'lastModified': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // D E L E T E
  Future<void> deleteTask(String docID) async {
    try {
      await tasks.doc(docID).delete();
    } catch (e) {
      rethrow;
    }
  }
} 