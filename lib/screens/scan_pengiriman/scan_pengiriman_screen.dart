import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
// import 'components/body.dart';

class ScanPengirimanScreen extends StatefulWidget {
  const ScanPengirimanScreen({Key? key}) : super(key: key);

  static var routeName = '/scan-pengiriman-screen';

  @override
  State<ScanPengirimanScreen> createState() => _ScanPengirimanScreenState();
}

class _ScanPengirimanScreenState extends State<ScanPengirimanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String noOrder = '';

  void initState() {
    super.initState();

    cameraController.stop();
  }

  // Function to show a custom dialog
  void showCustomDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Berhasil'),
          content: Text('No Surat Jalan Terdeteksi'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                if (noOrder.contains(';')) {
                  List<String> stringList = noOrder.split(";");
                  List<String> noOrderNitem = stringList[1].split("|");

                  // noOrder =
                  if (noOrder.isNotEmpty) {
                    Map<String, dynamic> data = {
                      "nomor_order": noOrderNitem[0],
                      "identifier": "YourIdentifierValue",
                      "sn": "YourSNValue",
                      "long": "YourLongitudeValue",
                      "lat": "YourLatitudeValue",
                      "location_id": 123,
                      "customer_id": 456,
                      "creator": "YourCreatorValue",
                      "date_added": "2023-11-06T12:34:56",
                      "date_modified": "2023-11-06T12:34:56",
                      "status": "unvalidasi",
                      "customer_nama": stringList[0],
                      "customer_notelp": "CustomerPhoneNumber",
                      "supir": "DriverName",
                      "items": "[]",
                    };
                    if (noOrderNitem.length > 2) {
                      data["qty_sum"] = noOrderNitem[2];
                    }

                    DatabaseHelper.instance.insertRecordTugas(data);
                  }
                }

                cameraController.start();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scan Pengiriman",
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
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              AudioPlayer().play(AssetSource('audio/success.mp3'));
              noOrder = barcode.rawValue!;
              debugPrint('Barcode found! ${barcode.rawValue}');
            }
            showCustomDialog(context);
            cameraController.stop();
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
