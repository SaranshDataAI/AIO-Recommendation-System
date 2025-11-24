import 'package:flutter/material.dart';
import '../../services/history_service.dart';
import '../../services/watchlist_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmAndRun(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF020617),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(message, style: const TextStyle(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await onConfirm();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Done')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Data & Privacy',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF020617),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('Clear watch history'),
                  subtitle: const Text(
                    'Remove all items from Continue Watching.',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap:
                      () => _confirmAndRun(
                        context,
                        title: 'Clear watch history?',
                        message:
                            'This will remove all locally stored watch history on this device.',
                        onConfirm: () async {
                          await HistoryService.clearHistory();
                        },
                      ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.bookmark_remove_outlined),
                  title: const Text('Clear My List'),
                  subtitle: const Text(
                    'Remove all items from your saved list.',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap:
                      () => _confirmAndRun(
                        context,
                        title: 'Clear My List?',
                        message:
                            'This will remove all titles you have added to My List on this device.',
                        onConfirm: () async {
                          await WatchlistService.clearWatchlist();
                        },
                      ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded),
                  title: const Text('Clear everything'),
                  subtitle: const Text(
                    'Reset watch history and My List.',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap:
                      () => _confirmAndRun(
                        context,
                        title: 'Clear all local data?',
                        message:
                            'This will clear both watch history and My List stored on this device.',
                        onConfirm: () async {
                          await HistoryService.clearHistory();
                          await WatchlistService.clearWatchlist();
                        },
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'About',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF020617),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('AIO Recommender'),
              subtitle: Text(
                'AI-powered cross-domain recommender for movies, anime & webseries.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
