import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:sqflite/sqflite.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../constants.dart';
import '../../controllers/form_tap_screen_controller.dart';
import '../../controllers/list_po_controller.dart';
import '../../enums.dart';
import 'components/body.dart';

class ScannerScreen extends StatefulWidget {
  static var routeName = '/scanner';

  ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _showMessage = false;
  String? barcodeRawVal = '';
  String? mesage = '';
  int _tipe = 0;

  MobileScannerController cameraController =
      MobileScannerController(detectionSpeed: DetectionSpeed.normal);

  ListPoController ctk = ListPoController();

  void initState() {
    final FormTapScreenController ctr = Get.put(FormTapScreenController());

    // To fix on start error
    cameraController.stop();
    ctr.kodeBT.value = '';
    super.initState();
  }

  bool _tr = true;

  // final FormTapScreenController ctl = Get.put(FormTapScreenController());

  Future<void> _dialogBuilder(BuildContext context, String prop) {
    final FormTapScreenController ctr = Get.put(FormTapScreenController());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('DATA TERDETEKSI',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Container(
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('\n'
                      'HASIL : ${prop}\n'),
                  Text(mesage!)
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('OK'),
              onPressed: () async {
                cameraController.start();
                await ctk.getListBt();
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
    final FormTapScreenController ctl = Get.put(FormTapScreenController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(28.0),
        child: AppBar(
          title: const Text('Mobile Scanner'),
          actions: [
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state as TorchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state as CameraFacing) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
      ),
      body: Stack(
        alignment: FractionalOffset.center,
        children: [
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.contain,
            startDelay: true,
            onDetect: (capture) async {
              cameraController.stop();

              final List<Barcode> barcodes = capture.barcodes.toList();

              for (final barcode in barcodes) {
                if (_tipe == 0) {
                  setState(() {
                    _tipe = 1;
                  });
                } else {
                  setState(() {
                    _tipe = 0;
                  });
                }

                final msg = await ctl.scanActV2(barcode.rawValue);
                if (ctl.errorSound.value) {
                  AudioPlayer().play(AssetSource('audio/failed.mp3'));
                } else {
                  AudioPlayer().play(AssetSource('audio/success.mp3'));
                }

                ctl.errorSound.value = false;
                setState(() {
                  print(barcode);
                  barcodeRawVal = '${barcode.rawValue}';
                  mesage = msg;
                });

                setState(() {
                  // _showMessage = false;
                });
                // AudioPlayer().play(AssetSource('audio/success.mp3'));
              }
              _dialogBuilder(context, barcodeRawVal!).then((value) {});
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${ctl.lastStatus.value}"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('SN  '),
                              Text('${ctl.detail_inv['serial_number'] ?? ''}')
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Identifier '),
                              Text('${ctl.detail_inv['identifier'] ?? ''} ')
                            ],
                          ),
                        ],
                      )),
                  // OutlinedButton(
                  //   onPressed: () {
                  //     // Add your button click logic here.
                  //     setState(() {
                  //       ctl.noSN.value = '';
                  //       ctl.lastStatus.value = '';
                  //       ctl.detail_inv['identifier'] = null;
                  //       ctl.detail_inv['serial_number'] = null;
                  //       cameraController.start();
                  //     });
                  //   },
                  //   child: Text('RESET SN DAN IDENTIFIER',
                  //       style: TextStyle(color: kPrimaryColor, fontSize: 10)),
                  //   style: OutlinedButton.styleFrom(
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(18.0),
                  //     ),
                  //     side: BorderSide(width: 1, color: kPrimaryColor),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _showMessage
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _showMessage = false;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => Text(
                            'BARCODE : ${barcodeRawVal} (${ctl.tipe})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: <Shadow>[
                                Shadow(
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                Shadow(
                                  blurRadius: 8.0,
                                  color: Color.fromARGB(125, 0, 0, 255),
                                ),
                              ],
                            ),
                          ).animate().fade(duration: 500.ms),
                        ),
                        Text(
                          '${mesage}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              Shadow(
                                blurRadius: 8.0,
                                color: Color.fromARGB(125, 0, 0, 255),
                              ),
                            ],
                          ),
                        ).animate().fade(duration: 500.ms),
                      ],
                    ),
                  )
                : null,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your button click logic here.
                    setState(() {
                      ctl.noSN.value = '';
                      ctl.lastStatus.value = '';
                      ctl.detail_inv['identifier'] = null;
                      ctl.detail_inv['serial_number'] = null;
                      cameraController.start();
                    });
                  },
                  child: Text('RESET SN DAN IDENTIFIER',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    side: BorderSide(width: 1, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            if (ctl.lastStatus.value != '') {
              // AudioPlayer().play(AssetSource('audio/success.mp3'));

              // Conditionally navigate back when shouldPop becomes true
              Future.delayed(Duration.zero, () {
                // Navigator.pop(context);
                cameraController.stop();
              });
            }
            return Text('');
          }),
          // Obx(
          //   () => Align(
          //     alignment: Alignment.center,
          //     child: ctl.lastStatus.value != ''
          //         ? Container(
          //             width: 400,
          //             height: 150,
          //             padding: EdgeInsets.all(20.0),
          //             decoration: BoxDecoration(
          //               color: Colors.white,
          //               borderRadius: BorderRadius.circular(10.0),
          //             ),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.stretch,
          //               children: [
          //                 Text(
          //                   '${ctl.lastStatus.value}',
          //                   style: TextStyle(
          //                     fontSize: 16.0,
          //                     fontWeight: FontWeight.bold,
          //                     color: Colors.black,
          //                   ),
          //                 ),
          //                 SizedBox(height: 10.0),
          //                 // ElevatedButton(
          //                 //   onPressed: () {
          //                 //     ctl.noSN.value = '';
          //                 //     ctl.lastStatus.value = '';
          //                 //   },
          //                 //   child: Text('Close'),
          //                 // ),
          //                 OutlinedButton(
          //                   onPressed: () {
          //                     // Add your button click logic here.
          //                     ctl.noSN.value = '';
          //                     ctl.lastStatus.value = '';
          //                     ctl.detail_inv['identifier'] = null;
          //                     ctl.detail_inv['serial_number'] = null;
          //                     // Navigator.pop(context);
          //                   },
          //                   child: Text('Close',
          //                       style: TextStyle(color: kPrimaryColor)),
          //                   style: OutlinedButton.styleFrom(
          //                     shape: RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(18.0),
          //                     ),
          //                     side: BorderSide(width: 1, color: kPrimaryColor),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           )
          //         : null,
          //   ),
          // )
        ],
      ),
    );
  }
}
