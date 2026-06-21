import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/constants.dart';
import '../../../models/scan_history.dart';
import '../../history/providers/history_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/scanner_provider.dart';
import '../widgets/zoom_slider.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _hasPermission = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller?.start();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
      });
      if (_hasPermission) {
        _initScanner();
      }
    }
  }

  void _initScanner() {
    final scannerState = ref.read(scannerProvider);
    _controller = MobileScannerController(
      torchEnabled: scannerState.isFlashOn,
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Stop scanning temporarily
    ref.read(scannerProvider.notifier).setScanning(false);

    // Save to history
    final type = ScanHistory.detectType(code);
    final scan = ScanHistory(
      content: code,
      type: type,
      scannedAt: DateTime.now(),
    );
    await ref.read(historyProvider.notifier).addScan(scan);

    if (mounted) {
      context.push('/result', extra: {'content': code, 'type': type}).then((_) {
        // Resume scanning when returning from result page
        setState(() {
          _isProcessing = false;
        });
        ref.read(scannerProvider.notifier).setScanning(true);
      });
    }
  }

  void _toggleFlash() async {
    ref.read(scannerProvider.notifier).toggleFlash();
    await _controller?.toggleTorch();
  }

  Future<void> _switchCamera() async {
    await _controller?.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);
    final settingsState = ref.watch(settingsProvider);

    // Sync auto zoom with settings
    if (scannerState.isAutoZoomEnabled != settingsState.autoZoomEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(scannerProvider.notifier)
            .setAutoZoom(settingsState.autoZoomEnabled);
        _controller?.updateScanWindow(Rect.largest);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(scannerState),
            // Scanner preview
            Expanded(
              child: _hasPermission
                  ? _buildScannerView()
                  : _buildPermissionDenied(),
            ),
            // Zoom slider
            if (_hasPermission) _buildZoomSlider(scannerState),
            // Bottom spacing
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ScannerState scannerState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.scanner,
            style: TextStyle(
              color: AppConstants.textLight,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              // Flash toggle
              IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  scannerState.isFlashOn
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: scannerState.isFlashOn
                      ? Colors.amber
                      : AppConstants.textLight,
                ),
                tooltip: 'Flash',
              ),
              // Switch camera (lens)
              IconButton(
                onPressed: _switchCamera,
                icon: const Icon(
                  Icons.cameraswitch,
                  color: AppConstants.textLight,
                ),
                tooltip: 'Switch Lens',
              ),
              // History
              IconButton(
                onPressed: () => context.push('/history'),
                icon: const Icon(
                  Icons.history,
                  color: AppConstants.textLight,
                ),
                tooltip: AppStrings.history,
              ),
              // Settings
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(
                  Icons.settings,
                  color: AppConstants.textLight,
                ),
                tooltip: AppStrings.settings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.primaryColor.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: MobileScanner(
            controller: _controller!,
                  onDetect: _onDetect,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomSlider(ScannerState scannerState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ZoomSlider(
        value: scannerState.currentZoom,
        min: AppConstants.minZoom,
        max: AppConstants.maxZoom,
        onChanged: (value) {
          ref.read(scannerProvider.notifier).setZoom(value);
          _controller?.setZoomScale(value);
        },
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            color: Colors.white54,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Izin kamera diperlukan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => openAppSettings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }
}