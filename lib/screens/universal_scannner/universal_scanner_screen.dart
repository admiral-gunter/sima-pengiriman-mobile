import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../scanner_offline/controller/scanner_offline_controller.dart';
import '../turun_barang_online/controllers/turun_barang_online_controller.dart';
import 'controller/universal_scanner_data.dart';

class UniversalScannerSCreen extends StatefulWidget {
  final dynamic goBackRouteName;
  UniversalScannerSCreen({Key? key, required this.goBackRouteName})
      : super(key: key);

  @override
  State<UniversalScannerSCreen> createState() => _UniversalScannerSCreenState();
}

class _UniversalScannerSCreenState extends State<UniversalScannerSCreen> {
  MobileScannerController cameraController =
      MobileScannerController(detectionSpeed: DetectionSpeed.normal);

  Map<String, dynamic> dataSNIdentifier = {'sn': null, 'identifier': null};
  var curKey = 'sn';
  final UniversalScannerData ctl = Get.put(UniversalScannerData());

  void initState() {
    // To fix on start error
    ctl.clearSnIdentifier();
    cameraController.stop();
    super.initState();
  }

  Future<void> _dialogBuilder(BuildContext context, String msg) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('DATA TERDETEKSI',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('${msg}\n'
              'VALUE : ${dataSNIdentifier[curKey]}\n'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('OK'),
              onPressed: () async {
                try {
                  setState(() {
                    ctl.updateSnIdentifier(curKey, dataSNIdentifier['sn']);
                  });

                  cameraController.start();
                  Navigator.of(context).pop();
                } catch (e) {
                  AudioPlayer().play(AssetSource('audio/failed.mp3'));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UniversalScannerData ctl = Get.put(UniversalScannerData());
    final TurunBarangOnlineController ctr =
        Get.put(TurunBarangOnlineController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, widget.goBackRouteName),
        ),
        title: const Text('Mobile Scanner'),
        actions: [
          IconButton(
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
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
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
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
      body: Stack(
        alignment: FractionalOffset.center,
        children: [
          MobileScanner(
            fit: BoxFit.contain,
            controller: cameraController,
            onDetect: (capture) async {
              cameraController.stop();
              List<dynamic> foundItem = [];

              final List<Barcode> barcodes = capture.barcodes;

              var barcode = barcodes[0].rawValue;

              final dataExists = await DatabaseHelper.instance
                  .doesDataExistBarangTurun(barcode!);

              setState(() {
                dataSNIdentifier[curKey] = barcode;
              });

              if (dataExists) {
                AudioPlayer().play(AssetSource('audio/failed.mp3'));
                _dialogBuilder(context, 'DATA DUPLIKAT').then((value) {});
                return;
              }

              final username = await SharedToken.univGetterString('username');
              for (var element in ctr.listInv) {
                if (element['inventory_id'] == barcode) {
                  print('waw ${barcode}');
                  print('${element['no_order']}');
                  final dataTurun = {
                    "nomor_order": element['no_order'],
                    "sn": barcode,
                    "identifier": element['identifier'],
                    "product_name": element['product_name'],
                    "long": "dummy_value",
                    "lat": "dummy_value",
                    "location_id": 0,
                    "customer_id": 0,
                    "creator": username,
                    "status": "unvalidasi",
                    "customer_nama": "COLUMN_TIDAK_TERPAKAI",
                    "customer_notelp": "COLUMN_TIDAK_TERPAKAI",
                    "supir": username,
                    "tapper": username
                  };
                  print(dataTurun);

                  // DatabaseHelper.instance.insertBarangTurun(dataTurun);
                  await ctr.insertDataTurun(dataTurun);
                  AudioPlayer().play(AssetSource('audio/success.mp3'));

                  _dialogBuilder(context, 'SN Tervalidasi').then((value) {});
                  return;
                }
              }

              if (foundItem.length == 0) {
                AudioPlayer().play(AssetSource('audio/failed.mp3'));
                _dialogBuilder(context, 'SN Tidak Valid').then((value) {});
                return;
              }

              AudioPlayer().play(AssetSource('audio/failed.mp3'));
              _dialogBuilder(context, 'SN Tidak Valid').then((value) {});
              return;
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text("${ctl.lastStatus.value}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SN  '),
                          Text('${dataSNIdentifier['sn'] ?? ''}')
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                      dataSNIdentifier = {'sn': null, 'identifier': null};
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
        ],
      ),
    );
  }
}
