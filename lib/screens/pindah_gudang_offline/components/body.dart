import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/screens/pindah_gudang_offline/pindah_gudang_offline_screen.dart';
import 'package:sima_pengiriman/screens/universal_scannner/controller/universal_scanner_data.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

import '../../../constants.dart';
import '../../../helper/database_helper.dart';
import '../../service_offline/controller/service_offline_controller.dart';
import '../../universal_scannner/universal_scanner_screen.dart';

class Body extends StatefulWidget {
  final String tipe;
  Body({Key? key, required this.tipe}) : super(key: key);
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Future<List<Map<String, dynamic>>> fetchData() async {
    return await DatabaseHelper.instance.getInventoryLocations();
  }

  List<Map<String, dynamic>> listLokasi = [];
  String tipePG = '';
  // final UniversalScannerData d = Get.put(UniversalScannerData());

  void initState() {
    tipePG = widget.tipe;
    // d.itemScanned.clear();
    // ctl.itemScanned.clear();
    fetchData().then((value) {
      setState(() {
        listLokasi.add({'id': '', 'text': 'Pilih Gudang'});
        listLokasi.addAll(value);
        // listLokasi[0]['id'] = '0';
        // listLokasi[0]['text'] = 'Pilih Gudang';
      });
    });
    super.initState();
  }

  void showSnackBar(
      BuildContext context, String message, int durationInSeconds) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(
          seconds: durationInSeconds), // Convert seconds to milliseconds
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final ServiceOfflineController ctr = Get.put(ServiceOfflineController());

    final UniversalScannerData ctl = Get.put(UniversalScannerData());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pilih Gudang',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
                value: ctr.basicCredential['dari_gudang'] ?? '',
                onChanged: (value) {
                  ctr.basicCredential['dari_gudang'] = value;
                  // ctl.updateCredentialBasic('location', newValue);
                },
                items: listLokasi.map((Map<String, dynamic> item) {
                  return DropdownMenuItem<String>(
                    value: item['id'].toString(),
                    child: Text(item['text']),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.0),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pilih Gudang',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
                value: ctr.basicCredential['ke_gudang'] ?? '',
                onChanged: (value) {
                  ctr.basicCredential['ke_gudang'] = value;
                  // ctl.updateCredentialBasic('location', newValue);
                },
                items: listLokasi.map((Map<String, dynamic> item) {
                  return DropdownMenuItem<String>(
                    value: item['id'].toString(),
                    child: Text(item['text']),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.0),
            ],
          ),
          TextFormField(
            initialValue: ctr.basicCredential['kd_pindah_gudang'],
            onChanged: (value) {
              ctr.basicCredential['kd_pindah_gudang'] = value;
            },
            decoration: InputDecoration(
              labelText: 'KD Pindah Gudang',
              labelStyle: TextStyle(
                color: Colors.black87,
                fontSize: 17,
              ),
            ),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 17,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          SizedBox(height: 25),
          Obx(
            () => Expanded(
              child: ListView.builder(
                itemCount: ctl.itemScanned.length,
                itemBuilder: (BuildContext context, int index) {
                  final data = ctl.itemScanned[index];
                  return Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0), // Adjust as needed
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('SN'),
                            Text(
                              '${data['sn'] ?? ''}  ',
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Identifier'),
                            Text(
                              '${data['identifier'] ?? ''} ',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                widget.tipe == 'terima'
                    ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UniversalScannerSCreen(
                              goBackRouteName: '/pindah-gudang-offline-terima'),
                        ),
                      )
                    : Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UniversalScannerSCreen(
                              goBackRouteName: '/pindah-gudang-offline-keluar'),
                        ),
                      );
              },
              child: Text('Scan SN dan Identifier',
                  style: TextStyle(color: kPrimaryColor)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(pfixRnded18),
                ),
                side: BorderSide(width: 1, color: kPrimaryColor),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                for (var i = 0; i < ctl.itemScanned.length; i++) {
                  // await SharedToken.univSetterString('pindah_gudang_offline',
                  //     ctr.basicCredential['identifier']);
                  final scan = ctl.itemScanned[i];
                  ctr.basicCredential['sn'] = scan['sn'];
                  ctr.basicCredential['identifier'] = scan['identifier'];
                  ctr.basicCredential['tipe'] = widget.tipe;
                  ctr.basicCredential['creator'] =
                      await SharedToken.univGetterString('username');
                  ctr.basicCredential['location_id'] =
                      await SharedToken.univGetterString('lokasi');

                  print(ctr.basicCredential);
                  final ms = await DatabaseHelper.instance
                      .insertPindahGudangOffline(ctr.basicCredential);
                  print(ms);
                }

                final e = await DatabaseHelper.instance.getDataPindahGudang();
                print(e);
                showSnackBar(context, 'Data Berhasil Dimasukkan Offline', 4);
              },
              child: Text('Submit', style: TextStyle(color: kPrimaryColor)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(pfixRnded18),
                ),
                side: BorderSide(width: 1, color: kPrimaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
