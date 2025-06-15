import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:keeper/screens/note_editor_screen.dart';
import 'package:keeper/services/firestore_service.dart';
import 'package:keeper/widgets/responsive_layout.dart';
import 'package:keeper/widgets/sync_status.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final FirestoreService _firestoreService;
  late final User _currentUser;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
  }

  Future<void> _initializeFirestore() async {
    _currentUser = FirebaseAuth.instance.currentUser!;
    _firestoreService = FirestoreService(uid: _currentUser.uid);
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmDelete(String docID) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Recycle Bin'),
        content: const Text('This note will be moved to the recycle bin. You can restore it later from the settings menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _firestoreService.deleteNote(docID);
              Navigator.pop(context);
            },
            child: const Text('Move to Bin'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getNotesStream(
              sortBy: settings.sortBy == SortBy.creationDate ? 'timestamp' : 'lastModified',
            ),
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
                List notesList = snapshot.data!.docs;

                if (notesList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No notes here yet'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ResponsiveLayout(
                    mobileBody: settings.viewMode == NotesView.list
                        ? _buildNotesList(notesList, settings)
                        : _buildNotesGrid(notesList, 2, settings),
                    tabletBody: _buildNotesGrid(notesList, 3, settings),
                    desktopBody: _buildNotesGrid(notesList, 4, settings),
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditorScreen(
                    firestoreService: _firestoreService,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildNotesList(List notesList, SettingsProvider settings) {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: notesList.length,
        itemBuilder: (context, index) {
          return _buildNoteCard(notesList[index], index, settings);
        },
      ),
    );
  }

  Widget _buildNotesGrid(List notesList, int crossAxisCount, SettingsProvider settings) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: notesList.length,
        itemBuilder: (context, index) {
          return _buildNoteCard(notesList[index], index, settings);
        },
      ),
    );
  }

  Widget _buildNoteCard(DocumentSnapshot document, int index, SettingsProvider settings) {
    String docID = document.id;
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String noteTitle = data['title'];
    String noteContent = data['content'];
    List<String> tags = data['tags'] ?? [];

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditorScreen(
                      firestoreService: _firestoreService,
                      docID: docID,
                      title: noteTitle,
                      content: noteContent,
                    ),
                  ),
                );
              },
              child: settings.viewMode == NotesView.list
                  ? ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'note_title_$docID',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  noteTitle,
                                  style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          SyncStatus(
                            hasPendingWrites: document.metadata.hasPendingWrites,
                            isFromCache: document.metadata.isFromCache,
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noteContent,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                                fontSize: settings.fontSize * 0.85,
                              ),
                            ),
                            if (tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  spacing: 4.0,
                                  runSpacing: 2.0,
                                  children: tags.map((tag) => Chip(
                                    label: Text(tag, style: TextStyle(fontSize: settings.fontSize * 0.7)),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(docID),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Hero(
                                        tag: 'note_title_$docID',
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Text(
                                            noteTitle,
                                            style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                                              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SyncStatus(
                                      hasPendingWrites: document.metadata.hasPendingWrites,
                                      isFromCache: document.metadata.isFromCache,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  noteContent,
                                  style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (tags.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Wrap(
                                      spacing: 4.0,
                                      runSpacing: 2.0,
                                      children: tags.map((tag) => Chip(
                                        label: Text(tag, style: TextStyle(fontSize: settings.fontSize * 0.7)),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )).toList(),
                                    ),
                                  ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () => _confirmDelete(docID),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
} 