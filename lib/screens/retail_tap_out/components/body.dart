import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/screens/grosir_tap_out/grosir_tap_out.dart';
import 'package:sima_pengiriman/screens/retail_tap_out/retail_tap_out_screen.dart';
import 'package:sima_pengiriman/screens/universal_scannner/controller/universal_scanner_data.dart';
import 'package:sima_pengiriman/screens/universal_scannner/universal_scanner_screen.dart';

import '../../../constants.dart';
import '../../../helper/database_helper.dart';
import '../../grosir_tap_out/controller/grosir_tap_out_controller.dart';
import '../../purchase_order_offline/components/dropdown_search.dart';
import '../../scanner_offline/controller/scanner_offline_controller.dart';
import '../controller/retail_tap_out_controller.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final RetailTapOutController ctl = Get.put(RetailTapOutController());

  var noOG =
      'OGOF-SM-${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}}';

  Future<List<Map<String, dynamic>>> fetchData() async {
    return await DatabaseHelper.instance.getInventoryLocations();
  }

  void initState() {
    // ctl.dataTap.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UniversalScannerData ctr = Get.put(UniversalScannerData());
    final ScannerOfflineController ctk = Get.put(ScannerOfflineController());

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchData(), // Call your asynchronous function here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final data = snapshot.data;

                return Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Lokasi',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                        ),
                        value: ctl.credentialBasic['location'] ?? null,
                        onChanged: (newValue) {
                          ctl.updateCredentialBasic('location', newValue);
                        },
                        items: data!.map((Map<String, dynamic> item) {
                          return DropdownMenuItem<String>(
                            value: item['id'].toString(),
                            child: Text(item['text']),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                );
              }
            },
          ),
          DropdownSearchWidget(),
          SizedBox(
            height: 25,
          ),
          Obx(
            () => SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: ListView.builder(
                  itemCount: ctr.itemScanned.length,
                  itemBuilder: (BuildContext context, int index) {
                    final data = ctr.itemScanned[index];
                    return Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 8.0), // Adjust as needed
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
          ),
          Expanded(child: SizedBox()),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Add your button click logic here.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UniversalScannerSCreen(
                        goBackRouteName: RetailTapOutScreen.routeName),
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                Map<String, dynamic> res = await ctl.insertDataOfflineTap(
                    ctr.itemScanned, ctk.credentialBasic['customer']);
                String messej = '';
                var color = Colors.green;
                messej = res['message'];
                if (!res['result']) {
                  color = Colors.red;
                }
                final snackBar = SnackBar(
                  content: Text(
                    messej,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: color,
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {
                      // Perform an action when the user clicks the "OK" button.
                    },
                  ),
                  duration:
                      Duration(milliseconds: 2500), // Set the duration here
                );

                // Show the SnackBar
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
