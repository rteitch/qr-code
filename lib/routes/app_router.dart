import 'package:go_router/go_router.dart';
import '../features/scanner/pages/scanner_page.dart';
import '../features/scanner/pages/result_page.dart';
import '../features/history/pages/history_page.dart';
import '../features/settings/pages/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/scanner',
  routes: [
    GoRoute(
      path: '/scanner',
      name: 'scanner',
      builder: (context, state) => const ScannerPage(),
    ),
    GoRoute(
      path: '/result',
      name: 'result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResultPage(
          content: extra?['content'] as String? ?? '',
          type: extra?['type'] as String? ?? 'TEXT',
        );
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);