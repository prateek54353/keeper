import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:keeper/screens/font_preview_screen.dart';

class FontSelectionScreen extends StatefulWidget {
  const FontSelectionScreen({super.key});

  @override
  State<FontSelectionScreen> createState() => _FontSelectionScreenState();
}

class _FontSelectionScreenState extends State<FontSelectionScreen> {
  // List of popular Google Fonts
  final List<String> _popularFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Oswald',
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'fontSettingsTitleHero',
          child: Material(
            color: Colors.transparent,
            child: const Text('Select Font'),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _popularFonts.length,
              itemBuilder: (context, index) {
                final String fontName = _popularFonts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      fontName,
                      style: GoogleFonts.getFont(fontName).copyWith(fontSize: 20),
                    ),
                    onTap: () {
                      settings.fontFamily = fontName;
                      Navigator.pop(context);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: '${fontName}_preview_hero',
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FontPreviewScreen(fontFamily: fontName),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (settings.fontFamily == fontName)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 