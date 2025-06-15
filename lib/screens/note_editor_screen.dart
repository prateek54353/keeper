import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keeper/services/firestore_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:keeper/providers/settings_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final FirestoreService firestoreService;
  final String? docID;
  final String? title;
  final String? content;
  final List<String>? tags;

  const NoteEditorScreen({
    super.key,
    required this.firestoreService,
    this.docID,
    this.title,
    this.content,
    this.tags,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<String> _tags = [];
  Timer? _debounce;
  bool _isNewNote = true;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title ?? '';
    _contentController.text = widget.content ?? '';
    _isNewNote = widget.docID == null;
    if (widget.tags != null) {
      _tags.addAll(widget.tags!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty || _tags.isNotEmpty) {
      if (_isNewNote) {
        widget.firestoreService.addNote(
          _titleController.text,
          _contentController.text,
          tags: _tags,
        );
        _isNewNote = false;
      } else {
        widget.firestoreService.updateNote(
          widget.docID!,
          _titleController.text,
          _contentController.text,
          tags: _tags,
        );
      }
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _saveNote();
    });
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
      });
      _tagController.clear();
      _saveNote();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _saveNote();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: Hero(
              tag: 'note_title_${widget.docID ?? "new"}',
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => _onTextChanged(),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _contentController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.getFont(settings.fontFamily).copyWith(
                    fontSize: settings.fontSize,
                  ),
                  onChanged: (_) => _onTextChanged(),
                ),
                const SizedBox(height: 16),
                // Tags Section
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    hintText: 'Add tags (e.g., #work, #personal)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addTag(_tagController.text),
                    ),
                  ),
                  onSubmitted: _addTag,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 