import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/components/coustom_bottom_nav_bar.dart';
import 'package:sima_pengiriman/enums.dart';
import 'package:sima_pengiriman/screens/barang_tidak_muat/controllers/barang_tidak_muat_controller.dart';

import '../../menu/menu_screen.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  MobileScannerController cameraController =
      MobileScannerController(detectionSpeed: DetectionSpeed.normal);

  @override
  void initState() {
    cameraController.stop();
    super.initState();
  }

  Future<void> showCustomDialog(
      BuildContext context, String? title, String? msg) async {
    if (title == null || title.isEmpty) {
      title = "Unknown";
    }

    if (msg == null || msg.isEmpty) {
      msg = "Unknown";
    }

    return showDialog<void>(
      context: context,
      barrierDismissible:
          true, // Set to false if you don't want the user to dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title!),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg!),
              ],
            ),
          ),
          actions: <Widget>[
            // TextButton(
            //   child: Text('Cancel'),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                cameraController.start();
                // Add your action here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctl = BarangTidakMuatController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scan Barang Tidak Muat",
          style: TextStyle(
            color: Colors
                .black, // Change this color to match your AppBar's background color.
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Custom back button behavior
          // You can add your custom logic here
          print(
              'Back button pressed!'); // Example: Print a message on back button press

          // Use Navigator to navigate to another screen when back button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MenuScreen()),
          );

          // Return true to allow back navigation, false to prevent it
          return false; // Set
        },
        child: MobileScanner(
          controller: cameraController,
          // fit: BoxFit.contain,
          onDetect: (capture) async {
            // capture.raw
            cameraController.stop();

            final List<Barcode> barcodes = capture.barcodes;

            for (final barcode in barcodes) {
              // barcode.rawValue!;
              final res = await ctl.makePostRequest(barcode.rawValue!);

              if (res['status'] == 'success') {
                AudioPlayer().play(AssetSource('audio/success.mp3'));
              } else {
                AudioPlayer().play(AssetSource('audio/failed.mp3'));
              }
              showCustomDialog(context, res['status'], res['msg']);
            }
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
