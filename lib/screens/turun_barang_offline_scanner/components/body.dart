import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool isFrontCamera = false;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: cameraController,
      onDetect: (barcode) {
        cameraController.stop();
        var code = barcode.barcodes[0].rawValue;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Barcode Scanned'),
              content: Text('Code: $code'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    cameraController.start();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
    // );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
