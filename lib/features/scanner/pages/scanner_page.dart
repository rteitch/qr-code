import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/constants.dart';
import '../../../models/scan_history.dart';
import '../../history/providers/history_provider.dart';
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
  bool _isInitialized = false;

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
    if (_controller == null || !_isInitialized) return;
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
    try {
      _controller = MobileScannerController();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Scanner init error: $e');
    }
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

    // Save to history
    final type = ScanHistory.detectType(code);
    final scan = ScanHistory(
      content: code,
      type: type,
      scannedAt: DateTime.now(),
    );

    try {
      await ref.read(historyProvider.notifier).addScan(scan);
    } catch (e) {
      debugPrint('History save error: $e');
    }

    if (mounted) {
      // Pause the scanner before navigating
      await _controller?.stop();

      context.push('/result', extra: {'content': code, 'type': type}).then((_) {
        // Resume scanning when returning from result page
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          _controller?.start();
        }
      });
    }
  }

  void _toggleFlash() async {
    try {
      await _controller?.toggleTorch();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller?.switchCamera();
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Scanner preview
            Expanded(
              child: _hasPermission && _isInitialized
                  ? _buildScannerView()
                  : _hasPermission
                      ? _buildLoading()
                      : _buildPermissionDenied(),
            ),
            // Zoom slider
            if (_hasPermission && _isInitialized) _buildZoomSlider(),
            // Bottom spacing
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final scannerState = ref.watch(scannerProvider);
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
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scanner Error',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        error.errorCode.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _controller?.dispose();
                        _initScanner();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildZoomSlider() {
    final scannerState = ref.watch(scannerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ZoomSlider(
        value: scannerState.currentZoom,
        min: AppConstants.minZoom,
        max: AppConstants.maxZoom,
        onChanged: (value) {
          ref.read(scannerProvider.notifier).setZoom(value);
          try {
            _controller?.setZoomScale(value / AppConstants.maxZoom);
          } catch (e) {
            debugPrint('Zoom error: $e');
          }
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppConstants.primaryColor),
          SizedBox(height: 16),
          Text(
            'Memulai kamera...',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
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