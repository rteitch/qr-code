import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/constants.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

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
          AppStrings.settings,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Auto Zoom section
          _buildSectionTitle('Scanner'),
          const SizedBox(height: 8),
          _buildSettingCard(
            icon: Icons.zoom_in,
            iconColor: AppConstants.primaryColor,
            title: AppStrings.autoZoom,
            subtitle: AppStrings.autoZoomDesc,
            trailing: Switch(
              value: settingsState.autoZoomEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setAutoZoom(value);
              },
              activeThumbColor: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          // App Info section
          _buildSectionTitle('Info Aplikasi'),
          const SizedBox(height: 8),
          _buildSettingCard(
            icon: Icons.info_outline,
            iconColor: Colors.white54,
            title: AppConstants.appName,
            subtitle: 'Versi ${AppConstants.appVersion}',
            trailing: null,
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.code,
            iconColor: Colors.white54,
            title: 'Platform',
            subtitle: 'Android & iOS (Flutter)',
            trailing: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}