import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keeper/screens/drawing_screen.dart';
import 'package:keeper/services/firestore_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final FirestoreService firestoreService;
  final String? docID;
  final String? title;
  final String? content;
  final List<String>? imageUrls;

  const NoteEditorScreen({
    super.key,
    required this.firestoreService,
    this.docID,
    this.title,
    this.content,
    this.imageUrls,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  bool _showToolbar = false;
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.docID != null) {
      _titleController.text = widget.title ?? '';
      _contentController.text = widget.content ?? '';
      if (widget.imageUrls != null) {
        _imageUrls.addAll(widget.imageUrls!);
      }
    }
    _titleFocusNode.addListener(_onFocusChange);
    _contentFocusNode.addListener(_onFocusChange);
    _contentController.addListener(_onContentChange);
  }

  @override
  void dispose() {
    _titleFocusNode.removeListener(_onFocusChange);
    _contentFocusNode.removeListener(_onFocusChange);
    _contentController.removeListener(_onContentChange);

    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showToolbar = _titleFocusNode.hasFocus || _contentFocusNode.hasFocus;
    });
  }

  void _onContentChange() {
    setState(() {
      // Rebuild to update character count
    });
  }

  void _saveNote() {
    if (_titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty ||
        _imageUrls.isNotEmpty) {
      if (widget.docID == null) {
        widget.firestoreService.addNote(
          _titleController.text,
          _contentController.text,
          imageUrls: _imageUrls,
        );
      } else {
        widget.firestoreService.updateNote(
          widget.docID!,
          _titleController.text,
          _contentController.text,
          imageUrls: _imageUrls,
        );
      }
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageUrl = await widget.firestoreService.uploadImage(File(image.path));
      setState(() {
        _imageUrls.add(imageUrl);
      });
    }
  }

  Future<void> _openDrawingPad() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DrawingScreen(firestoreService: widget.firestoreService),
      ),
    );
    if (result != null && result is String) {
      setState(() {
        _imageUrls.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.undo, color: theme.textTheme.bodyLarge?.color)),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.redo, color: theme.textTheme.bodyLarge?.color)),
          IconButton(
            onPressed: _saveNote,
            icon: Icon(Icons.check, color: theme.textTheme.bodyLarge?.color),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  maxLines: null,
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat.yMMMMd().add_jm().format(DateTime.now())} | ${_contentController.text.length} characters',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _contentController,
                          focusNode: _contentFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Start typing',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 18),
                          maxLines: null,
                        ),
                        ..._imageUrls.map((url) => Image.network(url)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _showToolbar
          ? BottomAppBar(
              elevation: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.mic_none)),
                  IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined)),
                  IconButton(
                      onPressed: _openDrawingPad,
                      icon: const Icon(Icons.gesture)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.check_box_outline_blank)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.text_fields)),
                ],
              ),
            )
          : null,
    );
  }
} 