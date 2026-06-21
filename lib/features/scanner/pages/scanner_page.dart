import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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

class _ScannerPageState extends ConsumerState<ScannerPage> {
  // Use a key to rebuild MobileScanner when retrying
  UniqueKey _scannerKey = UniqueKey();
  bool _isProcessing = false;
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _controller = MobileScannerController(
      autoStart: true,
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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

    // Pause the scanner
    await _controller?.stop();

    if (!mounted) return;

    context.push('/result', extra: {'content': code, 'type': type}).then((_) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _controller?.start();
      }
    });
  }

  void _retryScanner() {
    _controller?.dispose();
    setState(() {
      _scannerKey = UniqueKey();
      _createController();
    });
  }

  void _toggleFlash() async {
    try {
      await _controller?.toggleTorch();
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
            _buildHeader(),
            Expanded(child: _buildScannerView()),
            _buildZoomSlider(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              IconButton(
                onPressed: _toggleFlash,
                icon: const Icon(
                  Icons.flash_off,
                  color: AppConstants.textLight,
                ),
                tooltip: 'Flash',
              ),
              IconButton(
                onPressed: _switchCamera,
                icon: const Icon(
                  Icons.cameraswitch,
                  color: AppConstants.textLight,
                ),
                tooltip: 'Switch Lens',
              ),
              IconButton(
                onPressed: () => context.push('/history'),
                icon: const Icon(
                  Icons.history,
                  color: AppConstants.textLight,
                ),
                tooltip: AppStrings.history,
              ),
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
            key: _scannerKey,
            controller: _controller!,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              debugPrint('MobileScanner error: ${error.errorCode}');

              return Container(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam_off,
                          color: Colors.white38,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Kamera tidak tersedia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getErrorMessage(error.errorCode),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _retryScanner,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            placeholderBuilder: (context, child) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppConstants.primaryColor),
                      SizedBox(height: 16),
                      Text(
                        'Memulai kamera...',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(MobileScannerErrorCode errorCode) {
    switch (errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Izin kamera ditolak. Berikan izin kamera di Pengaturan aplikasi.';
      case MobileScannerErrorCode.unsupported:
        return 'Kamera tidak didukung pada perangkat ini.';
      case MobileScannerErrorCode.controllerUninitialized:
        return 'Scanner belum siap. Coba lagi dalam beberapa saat.';
      case MobileScannerErrorCode.genericError:
      default:
        return 'Terjadi kesalahan saat mengakses kamera. Pastikan tidak ada aplikasi lain yang menggunakan kamera.';
    }
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
}