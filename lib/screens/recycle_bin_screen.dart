import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keeper/services/firestore_service.dart';
import 'package:keeper/widgets/sync_status.dart';
import 'package:intl/intl.dart';

class RecycleBinScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const RecycleBinScreen({
    super.key,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'recycleBinTitleHero',
          child: Material(
            color: Colors.transparent,
            child: Text('Recycle Bin'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Empty Recycle Bin'),
                  content: const Text('Are you sure you want to permanently delete all notes in the recycle bin? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement empty recycle bin
                        Navigator.pop(context);
                      },
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getDeletedNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            List deletedNotesList = snapshot.data!.docs;

            if (deletedNotesList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Recycle bin is empty'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: deletedNotesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = deletedNotesList[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String docID = document.id;
                String title = data['title'] ?? '';
                String content = data['content'] ?? '';
                Timestamp? deletedAt = data['deletedAt'] as Timestamp?;

                return Dismissible(
                  key: Key(docID),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Permanently Delete'),
                        content: const Text('Are you sure you want to permanently delete this note? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    firestoreService.permanentlyDeleteNote(docID);
                  },
                  child: ListTile(
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (deletedAt != null)
                          Text(
                            'Deleted on ${DateFormat.yMMMd().add_jm().format(deletedAt.toDate())}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SyncStatus(
                          hasPendingWrites: document.metadata.hasPendingWrites,
                          isFromCache: document.metadata.isFromCache,
                        ),
                        IconButton(
                          icon: const Icon(Icons.restore),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Restore Note'),
                                content: const Text('Do you want to restore this note?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      firestoreService.restoreNote(docID);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Restore'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Permanently Delete Note'),
                                content: const Text('Are you sure you want to permanently delete this note? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      firestoreService.permanentlyDeleteNote(docID);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete Forever'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
} 