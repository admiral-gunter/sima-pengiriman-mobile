import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/screens/menu_select_customer/menu_select_customer.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../menu_select_customer/controllers/menu_select_customer_controller.dart';
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

  Future SJDalamPengiriman(dynamic data) async {
    final url =
        Uri.parse(kURL_ORIGIN + 'pengiriman/update-pengiriman-from-mobile');
    final sj = data.toString().replaceAll(' ', '');
    Map<String, dynamic> requestBody = {"sj": "'" + sj + "'", "status": "12"};

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: requestBody,
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
                  DateTime now = DateTime.now();
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
                      "date_added": now.toLocal().toString(),
                      "date_modified": now.toLocal().toString(),
                      "status": "unvalidasi",
                      "customer_nama": stringList[0],
                      "customer_notelp": "CustomerPhoneNumber",
                      "supir": "DriverName",
                      "items": "[]",
                    };
                    if (noOrderNitem.length > 2) {
                      data["qty_sum"] = noOrderNitem[2];
                    }

                    print(data);
                    final res =
                        await DatabaseHelper.instance.insertRecordTugas(data);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res['message']),
                        duration: const Duration(seconds: 1),
                        action: SnackBarAction(
                          label: 'ACTION',
                          onPressed: () {},
                        ),
                      ),
                    );

                    final MenuSelectCustomerController ctl =
                        Get.put(MenuSelectCustomerController());

                    if (!ctl.internetConnected.value) {
                      Navigator.pop(context);
                    }

                    await kirimData(data);
                    await SJDalamPengiriman(noOrderNitem[0]);
                  }
                }
                Navigator.pushReplacementNamed(
                    context, MenuSelectCustomer.routeName);

                // Navigator.pushReplacementNamed(context, MenuScreen.routeName);
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
          // Custom back button behavior
          // You can add your custom logic here
          print(
              'Back button pressed!'); // Example: Print a message on back button press

          // Use Navigator to navigate to another screen when back button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MenuSelectCustomer()),
          );

          // Return true to allow back navigation, false to prevent it
          return false; // Set
        },
        child: MobileScanner(
          controller: cameraController,
          // fit: BoxFit.contain,
          onDetect: (capture) async {
            final MenuSelectCustomerController ctl =
                Get.put(MenuSelectCustomerController());

            final List<Barcode> barcodes = capture.barcodes;

            for (final barcode in barcodes) {
              noOrder = barcode.rawValue!;
              debugPrint('Barcode found! ${barcode.rawValue}');
              cameraController.stop();
            }
            List<String> parts = noOrder.split('-');
            print(parts);
            String username = await SharedToken.univGetterString('username');
            if (parts[1] == username) {
              print('sama dong');
            }

            print('${parts[1]} supir di akun n ${username}');
            if (parts.length >= 2) {
              String supir = parts[1].split('--').first.trim();
              // if (supir != username) {
              //   AudioPlayer().play(AssetSource('audio/failed.mp3'));
              //   showErrorSupirMismatchDialog(context);
              //   return;
              // } else if (parts[0] != username) {
              //   AudioPlayer().play(AssetSource('audio/failed.mp3'));
              //   showErrorSupirMismatchDialog(context);
              //   return;
              // }

              if (supir != username && parts[1] != username) {
                AudioPlayer().play(AssetSource('audio/failed.mp3'));
                showErrorSupirMismatchDialog(context);
                return;
              }
            }

            if (!ctl.internetConnected.value) {
              showCustomDialog(context);
              AudioPlayer().play(AssetSource('audio/success.mp3'));
              return;
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
