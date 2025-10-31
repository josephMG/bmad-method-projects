import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/presentation/providers/sync_status_provider.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    String message = '';
    Color color = Colors.transparent;

    switch (syncStatus) {
      case SyncStatus.syncing:
        message = 'Syncing...';
        color = Colors.blue;
        break;
      case SyncStatus.synced:
        message = 'Last synced: Just now'; // TODO: Implement actual timestamp
        color = Colors.green;
        break;
      case SyncStatus.error:
        message = 'Sync Error!';
        color = Colors.red;
        break;
      case SyncStatus.offline:
        message = 'Offline';
        color = Colors.red;
        break;
      case SyncStatus.idle:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.all(4.0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}