import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Location location = Location();

  MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool isFrontCamera = false;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: cameraController,
      onDetect: (barcode) {
        cameraController.stop();
        var code = barcode.barcodes[0].rawValue.toString();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Barcode Scanned'),
              content: Text('Code: $code'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    LocationData locationData = await location.getLocation();
                    final String username =
                        await SharedToken.univGetterString('username');
                    final String platNo =
                        await SharedToken.univGetterString('plat_no');
//(String sn, String latitude, String longitude,String username, String dateAdded
                    DateTime now = DateTime.now();
                    String formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
                    DatabaseHelper.instance.insertSN(
                        code,
                        locationData.latitude.toString(),
                        locationData.longitude.toString(),
                        username,
                        formattedDate,
                        platNo);
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
