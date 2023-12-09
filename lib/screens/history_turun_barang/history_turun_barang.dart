import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/screens/universal_scannner/universal_scanner_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:sqflite/sqflite.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'package:location/location.dart';

import 'controllers/history_turun_barang_controller.dart';

class HistoryBarangScreen extends StatefulWidget {
  const HistoryBarangScreen({Key? key}) : super(key: key);
  static String routeName = "/history-turun-barang";

  @override
  State<HistoryBarangScreen> createState() =>
      _HistoryBarangScreenState();
}

class _HistoryBarangScreenState extends State<HistoryBarangScreen> {
  Location location = Location();

  late double latitude;

  late double longitude;

  TextEditingController textController = TextEditingController();

  TextEditingController TapperTextController = TextEditingController();

  String username = '';
  int totalBarangHarusDiTap = 0;

  @override
  void initState() {
    super.initState();
    _getLocationData();
    _getCountProduct();
    SharedToken.univGetterString('username').then((value) {
      if (mounted) {
        setState(() {
          TapperTextController.text = value;
          username = value;
        });
      }
    });
  }

  _getLocationData() async {
    try {
      LocationData locationData = await location.getLocation();
      if (mounted) {
        setState(() {
          latitude = locationData.latitude!;
          longitude = locationData.longitude!;
          textController.text = '${latitude}, ${longitude}';

          final HistoryTurunBarangController ctl =
              Get.put(HistoryTurunBarangController());
          ctl.coordinate['lat'] = latitude.toString();
          ctl.coordinate['long'] = longitude.toString();
        });
      }
    } catch (e) {
      // Handle errors, such as permissions or location services not enabled.
      print("Error getting location: $e");
    }
  }

  List<Map<String, dynamic>> output = [];
  var listBarangTapped = [];

  _getCountProduct() async {
    final HistoryTurunBarangController ctl =
        Get.put(HistoryTurunBarangController());
print(ctl.listInv);
    Map<String, int> productCount = {};
    Map<String, int> totalQtyMap = {};

    for (var item in ctl.listInv) {
      print(' el item ${item}');
      String productName = item['product_name'];
      int totalQty = await DatabaseHelper.instance
          .countBarangTap(item['product_name'], item['no_order']);

      final barangTap = await DatabaseHelper.instance.getAllBarangTap(
          item['product_name'], item['no_order'], item['inventory_id']);

      listBarangTapped.addAll(barangTap);

      productCount[productName] = (productCount[productName] ?? 0) + 1;
      totalQtyMap[productName] = totalQty;
    }
    List listBarangTappedTemp = [];

    listBarangTapped.forEach((element) {
      var productExists = listBarangTappedTemp
          .where((el) => el['product_name'] == element['product_name'])
          .toList();

      if (productExists.isNotEmpty) {
        // Product already exists in the temporary list, add 'sn' to the existing 'sn' list
        productExists[0]['sn'].add(element['sn']);
      } else {
        // Product doesn't exist in the temporary list, add a new entry
        listBarangTappedTemp.add({
          'product_name': element['product_name'],
          'sn': [element['sn']]
        });
      }
    });

    print(listBarangTappedTemp);
    setState(() {
      listBarangTapped = listBarangTappedTemp;
    });

    productCount.forEach((productName, count) {
      totalBarangHarusDiTap += count;

      output.add({
        "product_name": productName,
        "qty": count,
        "qty_tap": totalQtyMap[productName] ?? 0,
      });

    });
    print('wahhh ${jsonEncode(output)}');

    for (var currentItem in output) {
       bool quantitiesMatch = currentItem['qty_tap'] == currentItem['qty'];

    if (quantitiesMatch) {
      matchingQuantities++;
    }

    if (matchingQuantities == totalBarangHarusDiTap) {
      for (var element in ctl.listSJ) {
        // final item = jsonEncode(element['nomor_order']);
        // noSj += item + ',';
        final data = {
          "nomor_order": element['nomor_order'],
          "nama_toko": element['toko'],
          "creator": username,
          "status": "unvalidasi",
          "customer_nama": "Alice",
          "customer_notelp": "1234567890",
          "supir": "Mike",
          "tapper": "Sam"
        };

        DatabaseHelper.instance
            .insertHistorySuratJalan(data)
            .then((value) => null);
      }
    }
    }
   
  }

  Future<List<bool>> fetchCompletionStatuses() async {
    final HistoryTurunBarangController ctl =
        Get.put(HistoryTurunBarangController());

    List<bool> completionStatuses = [];

    for (var i = 0; i < ctl.listInv.length; i++) {
      var e = await ctl.detectCompletionItem(
          ctl.listInv[i]['no_order'], ctl.listInv[i]['inventory_id']);
      completionStatuses.add(e);
    }
    return completionStatuses;
  }

  int matchingQuantities = 0;

  @override
  Widget build(BuildContext context) {
    final HistoryTurunBarangController ctl =
        Get.put(HistoryTurunBarangController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
            title: Text(
          "History Turun Barang ",
          style: TextStyle(
            color: Colors
                .black, // Change this color to match your AppBar's background color.
          ),
        )),
      ),
      body: WillPopScope(
        onWillPop: () async {
          ctl.listInv.clear();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MenuScreen(),
              ));
          return false;
        },
        child: DefaultTabController(
          length: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              // spacing: 20,
              // runSpacing: 20,
              children: [
                TextFormField(
                  controller: TapperTextController,
                  enabled: false,
                  onChanged: (value) {
                    ctl.tapper.value = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Tapper',
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
                TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Tab(text: 'List'),
                    Tab(text: 'Hasil Tap'),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView.builder(
                          itemCount: output.length,
                          itemBuilder: ((context, index) {
                            var currentItem = output[index];

                           
                            return ListTile(
                              title: Text('${output[index]['product_name']}'),
                              trailing: Text(
                                  '${output[index]['qty_tap']}/${output[index]['qty']}'),
                            );
                          })),
                      ListView.builder(
                        itemCount: listBarangTapped.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var item in listBarangTapped[index]['sn'])
                                  Text(item),
                              ],
                            ),
                            title:
                                Text(listBarangTapped[index]['product_name']),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: textController.text.isNotEmpty
                                  ? Colors.blue
                                  : Colors.blue[200]),
                          onPressed: () {
                            if (textController.text.isNotEmpty) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UniversalScannerSCreen(
                                      goBackRouteName:
                                          HistoryBarangScreen.routeName),
                                ),
                              );
                            }
                          },
                          child: textController.text.isNotEmpty
                              ? Text(
                                  'Scan SN dan Identifier',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text('Getting current location..',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)))),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
