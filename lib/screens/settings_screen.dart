import 'package:flutter/material.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:keeper/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Font Size
                    ListTile(
                      leading: const Icon(Icons.format_size),
                      title: const Text('Font Size'),
                      subtitle: Slider(
                        value: settings.fontSize,
                        min: 12,
                        max: 24,
                        divisions: 6,
                        label: settings.fontSize.round().toString(),
                        onChanged: (value) => settings.fontSize = value,
                      ),
                    ),
                    const Divider(),

                    // View Mode
                    ListTile(
                      leading: const Icon(Icons.grid_view),
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
                        onSelectionChanged: (Set<NotesView> selected) {
                          settings.viewMode = selected.first;
                        },
                      ),
                    ),
                    const Divider(),

                    // Sort By
                    ListTile(
                      leading: const Icon(Icons.sort),
                      title: const Text('Sort By'),
                      trailing: SegmentedButton<SortBy>(
                        segments: const [
                          ButtonSegment(
                            value: SortBy.modificationDate,
                            label: Text('Modified'),
                          ),
                          ButtonSegment(
                            value: SortBy.creationDate,
                            label: Text('Created'),
                          ),
                        ],
                        selected: {settings.sortBy},
                        onSelectionChanged: (Set<SortBy> selected) {
                          settings.sortBy = selected.first;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Sign Out button at bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () => _signOut(context),
                    child: const Text('Sign Out'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
} 