import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:keeper/screens/font_selection_screen.dart';

class LookAndFeelScreen extends StatelessWidget {
  const LookAndFeelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'lookAndFeelTitleHero',
          child: Material(
            color: Colors.transparent,
            child: Text('Look and Feel'),
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Select Font'),
            subtitle: Text(settings.fontFamily),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FontSelectionScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: Text('${settings.fontSize.toInt()}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (settings.fontSize > 12) {
                      settings.fontSize = settings.fontSize - 1;
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (settings.fontSize < 24) {
                      settings.fontSize = settings.fontSize + 1;
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('View Mode'),
            trailing: SegmentedButton<NotesView>(
              segments: const [
                ButtonSegment(
                  value: NotesView.list,
                  icon: Icon(Icons.view_list),
                  label: Text('List'),
                ),
                ButtonSegment(
                  value: NotesView.grid,
                  icon: Icon(Icons.grid_view),
                  label: Text('Grid'),
                ),
              ],
              selected: {settings.viewMode},
              onSelectionChanged: (Set<NotesView> newSelection) {
                settings.viewMode = newSelection.first;
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_medium),
                  title: const Text('Select App Theme'),
                  subtitle: Text(settings.appThemeMode.toString().split('.').last),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 72.0, top: 8.0), // Adjust padding to align with other list items
                  child: SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: Icon(Icons.wb_sunny),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: Icon(Icons.nights_stay),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {settings.appThemeMode},
                    onSelectionChanged: (Set<AppThemeMode> newSelection) {
                      settings.appThemeMode = newSelection.first;
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Amoled palette'),
            subtitle: const Text('Best experienced on AMOLED displays'),
            secondary: const Icon(Icons.color_lens),
            value: settings.amoledPalette,
            onChanged: (bool value) {
              settings.amoledPalette = value;
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Material Theme'),
            subtitle: const Text('Theme based on your wallpaper'),
            secondary: const Icon(Icons.wallpaper),
            value: settings.materialTheme,
            onChanged: (bool value) {
              settings.materialTheme = value;
            },
          ),
        ],
      ),
    );
  }
} 