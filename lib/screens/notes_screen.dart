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
// Import for ImageFilter

// Performance optimization: Extract static widgets to avoid rebuilds
class _EmptyNotesView extends StatelessWidget {
  const _EmptyNotesView();

  @override
  Widget build(BuildContext context) => const Center(
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

  Future<void> _handleNoteTap(DocumentSnapshot document, SettingsProvider settings) async {
    final data = document.data() as Map<String, dynamic>;
    final docID = document.id;
    final noteTitle = data['title'] ?? '';
    final noteContent = data['content'] ?? '';

    if (mounted) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
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

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const _EmptyNotesView();
              }

              final notesList = snapshot.data!.docs;
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
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditorScreen(
                  firestoreService: _firestoreService,
                ),
              ),
            ),
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
        itemBuilder: (context, index) => _buildNoteCard(notesList[index], index, settings),
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
        itemBuilder: (context, index) => _buildNoteCard(notesList[index], index, settings),
      ),
    );
  }

  Widget _buildNoteCard(DocumentSnapshot document, int index, SettingsProvider settings) {
    final data = document.data() as Map<String, dynamic>;
    final String noteTitle = data['title'] ?? '';
    final String noteContent = data['content'] ?? '';

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () => _handleNoteTap(document, settings),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            noteTitle,
                            style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 