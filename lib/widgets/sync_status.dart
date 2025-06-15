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
      return Tooltip(
        message: 'Pending local changes',
        child: Icon(
          Icons.sync_outlined,
          size: 20,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      );
    }

    if (isFromCache) {
      return Tooltip(
        message: 'Data loaded from cache (offline)',
        child: Icon(
          Icons.cloud_off_outlined,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    return Tooltip(
      message: 'Data synced',
      child: Icon(
        Icons.cloud_done_outlined,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
} 