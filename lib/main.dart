import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/constants.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: QRScannerPro(),
    ),
  );
}

class QRScannerPro extends StatelessWidget {
  const QRScannerPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppConstants.primaryColor,
        scaffoldBackgroundColor: AppConstants.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.darkBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.darkBg,
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}