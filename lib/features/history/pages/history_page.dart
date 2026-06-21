import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/constants.dart';
import '../../../models/scan_history.dart';
import '../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppConstants.darkBg,
      appBar: AppBar(
        backgroundColor: AppConstants.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.history,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (historyState.scans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: AppStrings.deleteHistory,
              onPressed: () => _showDeleteAllDialog(context, ref),
            ),
        ],
      ),
      body: historyState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            )
          : historyState.scans.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(context, ref, historyState.scans),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            color: Colors.white24,
            size: 80,
          ),
          SizedBox(height: 16),
          Text(
            AppStrings.noHistory,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
      BuildContext context, WidgetRef ref, List<ScanHistory> scans) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: scans.length,
      itemBuilder: (context, index) {
        final scan = scans[index];
        return _buildHistoryItem(context, ref, scan);
      },
    );
  }

  Widget _buildHistoryItem(
      BuildContext context, WidgetRef ref, ScanHistory scan) {
    return Dismissible(
      key: Key(scan.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        if (scan.id != null) {
          ref.read(historyProvider.notifier).deleteScan(scan.id!);
        }
      },
      child: GestureDetector(
        onTap: () {
          context.push('/result', extra: {
            'content': scan.content,
            'type': scan.type,
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getTypeColor(scan.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    _getTypeIcon(scan.type),
                    color: _getTypeColor(scan.type),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd-MM-yyyy HH:mm').format(scan.scannedAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(scan.type)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            scan.type,
                            style: TextStyle(
                              color: _getTypeColor(scan.type),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardDark,
        title: const Text(
          AppStrings.deleteHistory,
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          AppStrings.deleteHistoryConfirm,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).deleteAllScans();
              Navigator.pop(context);
            },
            child: const Text(
              AppStrings.hapus,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'URL':
        return const Color(0xFF42A5F5);
      case 'WIFI':
        return const Color(0xFF66BB6A);
      case 'EMAIL':
        return const Color(0xFFEF5350);
      case 'PHONE':
        return const Color(0xFFAB47BC);
      case 'SMS':
        return const Color(0xFFFFA726);
      case 'CONTACT':
        return const Color(0xFF26C6DA);
      case 'LOCATION':
        return const Color(0xFF9CCC65);
      default:
        return const Color(0xFF78909C);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'WIFI':
        return Icons.wifi;
      case 'EMAIL':
        return Icons.email;
      case 'PHONE':
        return Icons.phone;
      case 'SMS':
        return Icons.sms;
      case 'CONTACT':
        return Icons.contact_page;
      case 'LOCATION':
        return Icons.location_on;
      default:
        return Icons.text_snippet;
    }
  }
}