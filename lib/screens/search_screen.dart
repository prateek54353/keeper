import 'package:flutter/material.dart';
import 'package:keeper/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:keeper/screens/note_editor_screen.dart';

class SearchScreen extends StatefulWidget {
  final FirestoreService firestoreService;

  const SearchScreen({super.key, required this.firestoreService});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'searchBarHero',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                border: InputBorder.none,
              ),
              style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              ),
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? const Center(child: Text('Start typing to search'))
          : StreamBuilder<QuerySnapshot>(
              stream: widget.firestoreService.notes
                  .where('isDeleted', isEqualTo: false)
                  .orderBy('lastModified', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toString().toLowerCase() ?? '';
                  final content = data['content']?.toString().toLowerCase() ?? '';
                  final query = _searchQuery.toLowerCase();
                  return title.contains(query) || content.contains(query);
                }).toList();

                if (notes.isEmpty) {
                  return const Center(child: Text('No matching notes found'));
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final document = notes[index];
                    final data = document.data() as Map<String, dynamic>;
                    final docID = document.id;
                    final noteTitle = data['title'] ?? '';
                    final noteContent = data['content'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          noteTitle,
                          style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          noteContent,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteEditorScreen(
                                firestoreService: widget.firestoreService,
                                docID: docID,
                                title: noteTitle,
                                content: noteContent,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
} 