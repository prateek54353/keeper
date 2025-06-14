import 'package:flutter/material.dart';

class SyncStatus extends StatelessWidget {
  final bool hasPendingWrites;
  final bool isFromCache;

  const SyncStatus({
    super.key,
    required this.hasPendingWrites,
    required this.isFromCache,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPendingWrites) {
      return const Icon(
        Icons.sync,
        size: 16,
        color: Colors.orange,
      );
    }

    if (isFromCache) {
      return const Icon(
        Icons.cloud_off,
        size: 16,
        color: Colors.grey,
      );
    }

    return const Icon(
      Icons.cloud_done,
      size: 16,
      color: Colors.green,
    );
  }
} 