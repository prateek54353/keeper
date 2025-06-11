import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeper/screens/note_editor_screen.dart';
import 'package:keeper/screens/notes_screen.dart';
import 'package:keeper/screens/settings_screen.dart';
import 'package:keeper/screens/tasks_screen.dart';
import 'package:keeper/services/firestore_service.dart';
import 'package:keeper/widgets/responsive_layout.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  late final FirestoreService _firestoreService;
  late final User _currentUser;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _firestoreService = FirestoreService(uid: _currentUser.uid);
    
    // Initialize screens with the FirestoreService instance
    _screens.addAll([
      const NotesScreen(),
      const TasksScreen(),
    ]);

    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        // User has signed out, navigate to auth screen
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              NoteEditorScreen(firestoreService: _firestoreService)),
    );
  }

  void _openAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: taskController,
            decoration: const InputDecoration(
              labelText: 'Task',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _firestoreService.addTask(taskController.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      tabletBody: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Notes' : 'Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            _navigateToAddNote();
          } else if (_selectedIndex == 1) {
            _openAddTaskDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Tasks',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Notes' : 'Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.note_outlined),
                selectedIcon: Icon(Icons.note),
                label: Text('Notes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check_box_outline_blank),
                selectedIcon: Icon(Icons.check_box),
                label: Text('Tasks'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            _navigateToAddNote();
          } else if (_selectedIndex == 1) {
            _openAddTaskDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 