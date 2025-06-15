import 'package:flutter/material.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:keeper/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:keeper/screens/recycle_bin_screen.dart';
import 'package:keeper/screens/about_screen.dart';
import 'package:keeper/screens/font_selection_screen.dart';
import 'package:keeper/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final user = FirebaseAuth.instance.currentUser!;
    final firestoreService = FirestoreService(uid: user.uid);

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
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: Hero(
                        tag: 'recycleBinTitleHero',
                        child: Material(
                          color: Colors.transparent,
                          child: const Text('Recycle Bin'),
                        ),
                      ),
                      subtitle: const Text('View and restore deleted notes'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecycleBinScreen(
                              firestoreService: firestoreService,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.font_download),
                      title: Hero(
                        tag: 'fontSettingsTitleHero',
                        child: Material(
                          color: Colors.transparent,
                          child: const Text('Select Font'),
                        ),
                      ),
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
                    ListTile(
                      leading: const Icon(Icons.sort),
                      title: const Text('Sort By'),
                      trailing: SegmentedButton<SortBy>(
                        segments: const [
                          ButtonSegment(
                            value: SortBy.modificationDate,
                            icon: Icon(Icons.edit),
                            label: Text('Modified'),
                          ),
                          ButtonSegment(
                            value: SortBy.creationDate,
                            icon: Icon(Icons.create),
                            label: Text('Created'),
                          ),
                        ],
                        selected: {settings.sortBy},
                        onSelectionChanged: (Set<SortBy> newSelection) {
                          settings.sortBy = newSelection.first;
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Hero(
                        tag: 'aboutKeeperTitleHero',
                        child: const Material(
                          color: Colors.transparent,
                          child: Text('About Keeper'),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
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