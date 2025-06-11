import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:keeper/services/firestore_service.dart';

class DrawingScreen extends StatefulWidget {
  final FirestoreService firestoreService;

  const DrawingScreen({super.key, required this.firestoreService});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late PainterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PainterController(
      settings: PainterSettings(
        freeStyle: const FreeStyleSettings(
          color: Colors.white,
          strokeWidth: 5,
        ),
      ),
    );
    _controller.background = Colors.black.backgroundDrawable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              if (_controller.drawables.isNotEmpty) {
                _controller.undo();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: FlutterPainter(
            controller: _controller,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: _showColorPicker,
            ),
            IconButton(
              icon: const Icon(Icons.brush),
              onPressed: _showThicknessPicker,
            ),
            IconButton(
              icon: const Icon(Icons.create, color: Colors.white),
              onPressed: () {
                _controller.freeStyleColor = Colors.white;
                _controller.freeStyleStrokeWidth = 5;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveDrawing() async {
    final image = await _controller.renderImage(const Size(1080, 1080));
    final Uint8List? data = await image.pngBytes;

    if (data != null) {
      final imageUrl = await widget.firestoreService.uploadDrawing(data);
      if (mounted) {
        Navigator.pop(context, imageUrl);
      }
    }
  }

  void _showColorPicker() async {
    Color? newColor = await showDialog<Color>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Select Color'),
              content: Wrap(
                children: [
                  for (final color in [
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.yellow,
                    Colors.white
                  ])
                    GestureDetector(
                      onTap: () => Navigator.pop(context, color),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(width: 2)),
                      ),
                    )
                ],
              ),
            ));
    if (newColor != null) {
      setState(() {
        _controller.freeStyleColor = newColor;
      });
    }
  }

  void _showThicknessPicker() async {
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Select Thickness'),
              content: StatefulBuilder(builder: (context, setDialogState) {
                return Slider(
                  value: _controller.freeStyleStrokeWidth,
                  min: 1,
                  max: 20,
                  onChanged: (value) {
                    setDialogState(() {
                      _controller.freeStyleStrokeWidth = value;
                    });
                  },
                );
              }),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            ));
  }
} 