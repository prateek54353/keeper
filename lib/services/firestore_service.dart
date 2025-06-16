import 'package:cloud_firestore/cloud_firestore.dart';

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
  
  CollectionReference get deletedNotes =>
      _db.collection('users').doc(uid).collection('deleted_notes');

  // C R E A T E
  Future<void> addNote(String title, String content, {bool isLocked = false}) async {
    try {
      await notes.add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
        'userId': uid,
        'isDeleted': false,
        'isLocked': isLocked,
      });
    } catch (e) {
      rethrow;
    }
  }

  // R E A D
  Stream<QuerySnapshot> getNotesStream({String? sortBy}) {
    try {
      final query = notes
          .where('isDeleted', isEqualTo: false)
          .orderBy(sortBy ?? 'lastModified', descending: true);
      return query.snapshots(includeMetadataChanges: true);
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getDeletedNotesStream() {
    try {
      return deletedNotes
          .orderBy('deletedAt', descending: true)
          .snapshots(includeMetadataChanges: true);
    } catch (e) {
      rethrow;
    }
  }

  // U P D A T E
  Future<void> updateNote(String docID, String newTitle, String newContent, {bool? isLocked}) async {
    try {
      Map<String, dynamic> updateData = {
        'title': newTitle,
        'content': newContent,
        'lastModified': FieldValue.serverTimestamp(),
      };
      if (isLocked != null) {
        updateData['isLocked'] = isLocked;
      }
      await notes.doc(docID).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  // D E L E T E
  Future<void> deleteNote(String docID) async {
    try {
      final noteDoc = await notes.doc(docID).get();
      if (noteDoc.exists) {
        final noteData = noteDoc.data() as Map<String, dynamic>;
        
        // Move to deleted_notes collection
        await deletedNotes.doc(docID).set({
          ...noteData,
          'deletedAt': FieldValue.serverTimestamp(),
        });

        // Mark as deleted in original collection
        await notes.doc(docID).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // R E S T O R E
  Future<void> restoreNote(String docID) async {
    try {
      final deletedNoteDoc = await deletedNotes.doc(docID).get();
      if (deletedNoteDoc.exists) {
        final noteData = deletedNoteDoc.data() as Map<String, dynamic>;
        
        // Restore in original collection
        await notes.doc(docID).update({
          'isDeleted': false,
          'deletedAt': null,
        });

        // Remove from deleted_notes collection
        await deletedNotes.doc(docID).delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // P E R M A N E N T L Y  D E L E T E
  Future<void> permanentlyDeleteNote(String docID) async {
    try {
      // Delete from deleted_notes collection
      await deletedNotes.doc(docID).delete();
      
      // Also delete from notes collection if it exists
      await notes.doc(docID).delete();
    } catch (e) {
      rethrow;
    }
  }
} 