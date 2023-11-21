import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/screens/service_offline/controller/service_offline_controller.dart';
import 'package:sima_pengiriman/screens/service_offline/service_offline_screen.dart';
import 'package:sima_pengiriman/screens/universal_scannner/universal_scanner_screen.dart';

import '../../../constants.dart';
import '../../../helper/database_helper.dart';
import '../../../shared_preferences/shared_token.dart';
import '../../universal_scannner/controller/universal_scanner_data.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Future<List<Map<String, dynamic>>> fetchJenisService() async {
    // Your JSON data.
    String jsonData = '''
    [
      {
        "value": "",
        "text": "Pilih Service"
      },
      {
        "value": "in_stock",
        "text": "Stock Sendiri"
      },
      {
        "value": "customer_retail",
        "text": "Customer Retail"
      },
      {
        "value": "customer_grosir",
        "text": "Customer Grosir"
      },
      {
        "value": "titip_service",
        "text": "Titip Service"
      }
    ]
  ''';

    // Parse the JSON data into a list of maps.
// Parse the JSON data into a list of maps.
    List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(json.decode(jsonData));

    return data;
  }

  Future<List<Map<String, dynamic>>> fetchSolusi() async {
    String jsonData = ''' [
    {
      "value": "",
      "text": "Pilih Service"
    },
    {
      "value": "service_barang",
      "text": "Service"
    },
    {
      "value": "order_kelengkapan",
      "text": "Order Kelengkapan"
    },
    {
      "value": "potong_bon",
      "text": "Potong Bon"
    },
    {
      "value": "tukar_guling",
      "text": "Tukar Guling"
    },
    {
      "value": "returan_customer",
      "text": "Retur Costumer"
    },
    {
      "value": "barang_out_order",
      "text": "Barang Tanpa Status"
    }
  ]''';
    List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(json.decode(jsonData));

    return data;
  }

  Future<List<Map<String, dynamic>>> fetchCustomerRetail() async {
    final token = await SharedToken.tokenGetter();
    final companyId = await SharedToken.companyGetter();
    final apiUrl = '${kURL_ORIGIN}select2/get-raw-cs/${companyId}/${token}';

    try {
      String jsonData = '''
    [
      {
        "id": "9999999",
        "text": "DUMMY"
      },
      {
        "id": "9999999",
        "text": "Dumy"
      },
      {
        "id": "9999999",
        "text": "Dumy"
      },
      {
        "id": "9999999",
        "text": "Dummy"
      },
      {
        "id": "9999999",
        "text": "DUmyyy"
      }
    ]
  ''';

      // Parse the JSON data into a list of maps.
// Parse the JSON data into a list of maps.
      List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(json.decode(jsonData));

      return data;
    } catch (e) {
      throw Exception('Error: $e');
    }
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

  List<Map<String, dynamic>> dataDropdown = [];
  List<Map<String, dynamic>> dataDropdownSolusi = [];
  void initState() {
    // d.itemScanned.clear();
    // ctl.itemScanned.clear();
    fetchJenisService().then((value) {
      setState(() {
        dataDropdown.addAll(value);
      });
    });

    fetchSolusi().then((value) {
      setState(() {
        dataDropdownSolusi.addAll(value);
      });
    });
    dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
    ctr.basicCredential['tanggal_service'] =
        "${selectedDate.toLocal()}".split(' ')[0];
    super.initState();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    return await DatabaseHelper.instance.getInventoryLocations();
  }

  Map<String, dynamic> basicCredential = {};
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  final ServiceOfflineController ctr = Get.put(ServiceOfflineController());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        ctr.changeBasicCredential('tanggal_service', picked);
        selectedDate = picked;
        dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ServiceOfflineController ctr = Get.put(ServiceOfflineController());
    final UniversalScannerData ctl = Get.put(UniversalScannerData());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Tipe',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              value: ctr.basicCredential['tipe'],
              onChanged: (newValue) {
                ctr.changeBasicCredential('tipe', newValue);
                setState(() {
                  basicCredential['tipe'] = newValue;
                });
                // ctl.updateCredentialBasic('location', newValue);
              },
              items: dataDropdown.map((Map<String, dynamic> item) {
                return DropdownMenuItem<String>(
                  value: item['value'].toString(),
                  child: Text(item['text'].toString()),
                );
              }).toList(),
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Solusi',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              value: ctr.basicCredential['solusi'],
              onChanged: (newValue) {
                ctr.changeBasicCredential('solusi', newValue);
                setState(() {
                  basicCredential['solusi'] = newValue;
                });
                // ctl.updateCredentialBasic('location', newValue);
              },
              items: dataDropdown.map((Map<String, dynamic> item) {
                return DropdownMenuItem<String>(
                  value: item['value'].toString(),
                  child: Text(item['text'].toString()),
                );
              }).toList(),
            ),
            SizedBox(
              height: 10,
            ),
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
                            labelText: 'Cabang/Toko',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                          ),
                          value: ctr.basicCredential['location_id'] ?? null,
                          onChanged: (newValue) {
                            ctr.changeBasicCredential('location_id', newValue);
                          },
                          items: data!.map((Map<String, dynamic> item) {
                            return DropdownMenuItem<String>(
                              value: item['id'].toString(),
                              child: Text(item['text']),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  );
                }
              },
            ),
            TextFormField(
              initialValue: ctr.basicCredential['customer_nama'],
              onChanged: (value) {
                ctr.changeBasicCredential('customer_nama', value);
              },
              decoration: InputDecoration(
                labelText: 'Nama Customer ',
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                ),
              ),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              initialValue: ctr.basicCredential['customer_notelp'],
              onChanged: (value) {
                ctr.changeBasicCredential('customer_notelp', value);
              },
              decoration: InputDecoration(
                labelText: 'No HP/Telp',
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                ),
              ),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Pilih Tanggal',
                    labelStyle: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: ctl.itemScanned.length,
                  itemBuilder: (BuildContext context, int index) {
                    final data = ctl.itemScanned[index];
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
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UniversalScannerSCreen(
                              goBackRouteName:
                                  ServiceOfflineScreen.routeName)));
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
                    final scan = ctl.itemScanned[i];
                    ctr.basicCredential['sn'] = scan['sn'];
                    ctr.basicCredential['identifier'] = scan['identifier'];
                    ctr.basicCredential['creator'] =
                        await SharedToken.univGetterString('username');

                    final ms = await DatabaseHelper.instance
                        .insertServiceOffline(ctr.basicCredential);
                    print(ms);
                  }
                  final i = await DatabaseHelper.instance.getDataService();
                  print(i);
                  showSnackBar(
                      context, 'Data Berhasil Dimasukkan (Offline)', 4);
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
      ),
    );
  }
}
