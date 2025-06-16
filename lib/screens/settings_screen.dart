import 'package:flutter/material.dart';
import 'package:keeper/providers/settings_provider.dart';
import 'package:keeper/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:keeper/screens/recycle_bin_screen.dart';
import 'package:keeper/screens/about_screen.dart';
import 'package:keeper/screens/look_and_feel_screen.dart';
import 'package:keeper/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  final FirestoreService firestoreService;
  const SettingsScreen({super.key, required this.firestoreService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

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
                      title: const Hero(
                        tag: 'recycleBinTitleHero',
                        child: Material(
                          color: Colors.transparent,
                          child: Text('Recycle Bin'),
                        ),
                      ),
                      subtitle: const Text('View and restore deleted notes'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecycleBinScreen(
                              firestoreService: widget.firestoreService,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Hero(
                        tag: 'lookAndFeelTitleHero',
                        child: Material(
                          color: Colors.transparent,
                          child: Text('Look and Feel'),
                        ),
                      ),
                      subtitle: const Text('Customize font, size, and view mode'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LookAndFeelScreen(),
                          ),
                        );
                      },
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
                      title: const Hero(
                        tag: 'aboutKeeperTitleHero',
                        child: Material(
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
                    const Divider(),
                  ],
                ),
              ),
              // Sign Out button at bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await AuthService().signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 