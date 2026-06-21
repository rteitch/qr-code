import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner_pro/main.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const QRScannerPro());
    expect(find.text('QR Scanner'), findsOneWidget);
  });
}