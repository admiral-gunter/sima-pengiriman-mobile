import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  Location location = Location();

  late double latitude;

  late double longitude;

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
      // Handle errors, such as permissions or location services not enabled.
      print("Error getting location: $e");
    }
  }

  Future<bool> sendPostRequest() async {
    List<String> stringList = noOrder.split(";");
    List<String> noOrderNitem = stringList[1].split("|");
    String apiUrl = kURL_ORIGIN + 'pengiriman/check-sj-duplicate?no_order';

    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST', Uri.parse(apiUrl));
    var noOrderReq = noOrderNitem[0].replaceAll(' ', '');
    request.bodyFields = {'no_order': noOrderReq};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String res = await response.stream.bytesToString();
      Map resMap = jsonDecode(res);

      return resMap['content'];
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future kirimData(dynamic data) async {
    final url = Uri.parse(kURL_ORIGIN + 'pengiriman/insert-record-tugas');
    Map<String, dynamic> requestBody = {"data": data};

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"data": jsonEncode(requestBody)},
      );

      if (response.statusCode == 200) {
        print('POST request successful! Response:');
        print(response.body);
      } else {
        print('POST request failed with status: ${response.statusCode}');
        print(response.body);
      }
    } catch (error) {
      print('Error making POST request: $error');
    }
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
              onPressed: () async {
                if (noOrder.contains(';')) {
                  List<String> stringList = noOrder.split(";");
                  List<String> noOrderNitem = stringList[1].split("|");
                  final username =
                      await SharedToken.univGetterString('username');
                  // noOrder =
                  if (noOrder.isNotEmpty) {
                    Map<String, dynamic> data = {
                      "nomor_order": noOrderNitem[0],
                      "identifier": "YourIdentifierValue",
                      "sn": "YourSNValue",
                      "long": longitude.toString(),
                      "lat": latitude.toString(),
                      "location_id": 123,
                      "customer_id": 456,
                      "creator": username,
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

                    await kirimData(data);

                    await DatabaseHelper.instance.insertRecordTugas(data);
                  }
                }
                Navigator.pushReplacementNamed(context, MenuScreen.routeName);
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
          onDetect: (capture) async {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              noOrder = barcode.rawValue!;
              debugPrint('Barcode found! ${barcode.rawValue}');
              cameraController.stop();
            }
            final cekDuplicate = await sendPostRequest();
            print(cekDuplicate);
            if (cekDuplicate) {
              showCustomDialog(context);
              AudioPlayer().play(AssetSource('audio/success.mp3'));
            } else {
              showErrorDialog(context);

              AudioPlayer().play(AssetSource('audio/failed.mp3'));
            }
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
