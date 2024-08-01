import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScanScreen extends StatefulWidget {
  @override
  _QRCodeScanScreenState createState() => _QRCodeScanScreenState();
}

class _QRCodeScanScreenState extends State<QRCodeScanScreen> {
  String? _result;
  final MobileScannerController _controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              if (barcode.rawValue != null) {
                setState(() {
                  _result = barcode.rawValue;
                });
                _controller.stop();
              }
            },
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: CutoutClipper(),
                  child: Container(
                    color: Colors.amber.shade100.withOpacity(0.9),
                  ),
                ),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 4.0),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Text(
              'Scan a QR Code to Pay',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          if (_result != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Text(
                  'Result: $_result',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
            size: MediaQuery.of(context).size,
            title: 'Show my QR',
            onPressed: () {
              GoRouter.of(context).pushNamed(AppRouteConst.qrCodeRoute);
            }),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CutoutClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 250,
            height: 250),
        Radius.circular(16.0),
      ))
      ..fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
