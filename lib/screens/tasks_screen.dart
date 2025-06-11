import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:keeper/services/firestore_service.dart';
import 'package:keeper/widgets/responsive_layout.dart';
import 'package:keeper/widgets/sync_status.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final FirestoreService _firestoreService;
  late final User _currentUser;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
  }

  Future<void> _initializeFirestore() async {
    _currentUser = FirebaseAuth.instance.currentUser!;
    _firestoreService = FirestoreService(uid: _currentUser.uid);
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _refresh() async {
    // Force a rebuild which will re-fetch data
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            List tasksList = snapshot.data!.docs;

            if (tasksList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_box_outline_blank, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No tasks yet'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ResponsiveLayout(
                mobileBody: _buildTasksList(tasksList),
                tabletBody: _buildTasksGrid(tasksList, 2),
                desktopBody: _buildTasksGrid(tasksList, 4),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTasksList(List tasksList) {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: tasksList.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(tasksList[index], index);
        },
      ),
    );
  }

  Widget _buildTasksGrid(List tasksList, int crossAxisCount) {
    return AnimationLimiter(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 4 / 1,
        ),
        itemCount: tasksList.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(tasksList[index], index);
        },
      ),
    );
  }

  Widget _buildTaskCard(DocumentSnapshot document, int index) {
    String docID = document.id;

    Map<String, dynamic> data =
        document.data() as Map<String, dynamic>;
    String taskTitle = data['title'];
    bool isDone = data['isDone'];

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: CheckboxListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      taskTitle,
                      style: TextStyle(
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  SyncStatus(
                    hasPendingWrites: document.metadata.hasPendingWrites,
                    isFromCache: document.metadata.isFromCache,
                  ),
                ],
              ),
              value: isDone,
              onChanged: (value) {
                _firestoreService.updateTaskStatus(docID, value!);
              },
              secondary: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _firestoreService.deleteTask(docID);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
} 