import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/courier_delivery_task_detail/delivery_task_detail.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'components/body.dart';

class CourierScannerScreen extends StatefulWidget {
  const CourierScannerScreen({Key? key}) : super(key: key);

  static var routeName = '/courier-scanner-screen';

  @override
  State<CourierScannerScreen> createState() => _ScanPengirimanScreenState();
}

class _ScanPengirimanScreenState extends State<CourierScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String noOrder = '';
  Location location = Location();

  late double latitude;

  late double longitude;

  @override
  void initState() {
    cameraController.stop();
    super.initState();
    _getLocationData();
  }

  _getLocationData() async {
    try {
      LocationData locationData = await location.getLocation();
      if (mounted) {
        setState(() {
          latitude = locationData.latitude!;
          longitude = locationData.longitude!;
          cameraController.start();
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  String orderCode = '';

  Future _updateTask() async {
    try {
      final assignedCourier = await SharedToken.univGetterString('username');
      final userId = await SharedToken.univGetterString('user_id');
      final orderCode =
          await SharedToken.univGetterString('selected_order_code');
      final response = await http.post(
        Uri.parse(
            '${kURL_ORIGIN}pengiriman/kurir/update-supir-task?courier_id=$userId&order_code=$orderCode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {}
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('error: $e');
    }
  }

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
              onPressed: () async {
                orderCode =
                    await SharedToken.univGetterString('selected_order_code');
                await _updateTask();
                Navigator.pushReplacementNamed(
                    context, DeliveryTaskDetail.routeName);
              },
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gagal'),
          content: Text('No Surat Jalan Sudah dikerjakan!'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                cameraController.start();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void showErrorSupirMismatchDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gagal'),
          content: Text('Supir Tidak sesuai dengan surat jalan!'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                cameraController.start();
                Navigator.pop(context);
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
          print(
              'Back button pressed!'); // Example: Print a message on back button press

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MenuScreen()),
          );

          return false; // Set
        },
        child: MobileScanner(
          controller: cameraController,
          // fit: BoxFit.contain,
          onDetect: (capture) async {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              noOrder = barcode.rawValue!;
              debugPrint('Barcode found! ${barcode.rawValue}');
              cameraController.stop();
              showCustomDialog(context);
            }
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
