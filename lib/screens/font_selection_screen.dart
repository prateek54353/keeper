import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:keeper/screens/font_preview_screen.dart';

// Performance optimization: Extract static widgets
class _FontPreviewButton extends StatelessWidget {
  final String fontName;
  final bool isDownloaded;

  const _FontPreviewButton({
    required this.fontName,
    required this.isDownloaded,
  });

  @override
  Widget build(BuildContext context) => Hero(
        tag: '${fontName}_preview_hero',
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FontPreviewScreen(
                  fontFamily: fontName,
                  isDownloaded: isDownloaded,
                ),
              ),
            ),
          ),
        ),
      );
}

class FontSelectionScreen extends StatelessWidget {
  const FontSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'fontSettingsTitleHero',
          child: Material(
            color: Colors.transparent,
            child: Text('Select Font'),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: settings.availableFonts.length,
        itemBuilder: (context, index) {
          final String fontName = settings.availableFonts[index];
          final bool isDownloaded = settings.isFontDownloaded(fontName);
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(
                fontName,
                style: isDownloaded
                    ? GoogleFonts.getFont(fontName).copyWith(fontSize: 20)
                    : const TextStyle(fontSize: 20),
              ),
              onTap: () {
                if (isDownloaded) {
                  settings.fontFamily = fontName;
                  Navigator.pop(context);
                } else {
                  _showDownloadDialog(context, fontName, settings);
                }
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FontPreviewButton(
                    fontName: fontName,
                    isDownloaded: isDownloaded,
                  ),
                  if (!isDownloaded)
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => _showDownloadDialog(context, fontName, settings),
                    ),
                  if (settings.fontFamily == fontName)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDownloadDialog(
    BuildContext context,
    String fontName,
    SettingsProvider settings,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download $fontName?'),
          content: const Text(
            'This font will be downloaded to your device. You can use it offline after downloading.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Download'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await settings.downloadFont(fontName);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$fontName downloaded successfully'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to download $fontName: $e'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
} 