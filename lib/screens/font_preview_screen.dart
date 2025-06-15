import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontPreviewScreen extends StatelessWidget {
  final String fontFamily;

  const FontPreviewScreen({super.key, required this.fontFamily});

  final String _loremIpsumText = 
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: '${fontFamily}_preview_hero',
          child: Material(
            color: Colors.transparent,
            child: Text('Preview: $fontFamily'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _loremIpsumText,
          style: GoogleFonts.getFont(fontFamily).copyWith(
            fontSize: 18,
            height: 1.5,
          ),
        ),
      ),
    );
  }
} 