import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/maps_view/controllers/maps_view_controller.dart';
import 'package:sima_pengiriman/screens/maps_view/maps_view.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/screens/universal_scannner/universal_scanner_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'package:location/location.dart';
import 'package:flutter_background/flutter_background.dart';
import 'controllers/turun_barang_online_controller.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class TurunBarangOnlineScreen extends StatefulWidget {
  const TurunBarangOnlineScreen({Key? key}) : super(key: key);
  static String routeName = "/turun-barang-online";

  @override
  State<TurunBarangOnlineScreen> createState() =>
      _TurunBarangOnlineScreenState();
}

class _TurunBarangOnlineScreenState extends State<TurunBarangOnlineScreen> {
  Location location = Location();
  bool sjDibatalkan = false;

  late double latitude;
  late double longitude;

  TextEditingController textController = TextEditingController();
  TextEditingController TapperTextController = TextEditingController();

  String username = '';
  int totalBarangHarusDiTap = 0;

  final LocationSettings locationSettings = LocationSettings(
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    _getLocationData();
    _getCountProduct();
    SharedToken.univGetterString('username').then((value) {
      if (mounted) {
        SharedToken.univGetterString('no_plat').then((no_plat) {
          if (mounted) {
            setState(() {
              TapperTextController.text = '${value} (${no_plat}) ';
            });
          }
        });
      }
    });
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
      // do what you want to do with the position here
      if (mounted) {
        setState(() async {
          // currentLocation = LatLng(position!.latitude, position!.longitude);
          await _addLokasiFirebaseFromLok(position!);
        });
      }
    }, onError: (error) {
      print("Error getting location: $error");
      // Handle error appropriately
    });
    Timer.periodic(Duration(seconds: 3), (Timer timer) async {
      try {
        await _getLocationData();
        // final DatabaseReference dashboardLive = FirebaseDatabase.instance
        //     .ref('realtime_supir_dashboard/${username}');
        // await dashboardLive
        //     .set({"lat": latitude.toString(), "long": longitude.toString()});
        // print('aduhai');
      } catch (e) {
        // Handle the exception as per your requirement
        print('Error we: $e');
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

          final TurunBarangOnlineController ctl =
              Get.put(TurunBarangOnlineController());
          ctl.coordinate['lat'] = latitude.toString();
          ctl.coordinate['long'] = longitude.toString();
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  List<Map<String, dynamic>> output = [];
  var listBarangTapped = [];

  Future<void> _postRequestSJDone(String nomorSJ) async {
    nomorSJ = nomorSJ.replaceAll(' ', '');
    final String apiUrl =
        kURL_ORIGIN + 'sale-wholesale/save-sj-done?no_sj=${nomorSJ}';

    Map<String, dynamic> data = {
      'key1': 'value1',
      'key2': 'value2',
    };
    String jsonData = jsonEncode(data);
    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  _getCountProduct() async {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    Map<String, int> productCount = {};
    Map<String, int> totalQtyMap = {};

    for (var item in ctl.listInv) {
      String productName = item['product_name'] ?? 'Unknown??';
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
        productExists[0]['sn'].add(element['sn']);
      } else {
        listBarangTappedTemp.add({
          'product_name': element['product_name'],
          'sn': [element['sn']]
        });
      }
    });
    int matchingQuantities = 0;

    if (mounted) {
      setState(() {
        listBarangTapped = listBarangTappedTemp;
      });
    }

    productCount.forEach((productName, count) {
      totalBarangHarusDiTap += count;

      var tapped = totalQtyMap[productName] ?? 0;

      listBarangTapped.forEach((item) {
        if (item['product_name'] == productName) {
          tapped = item['sn'].length;
        }
      });
      if (mounted) {
        setState(() {
          output.add({
            "product_name": productName,
            "qty": count,
            "qty_tap": tapped,
          });
        });
      }
    });

    if (mounted) {
      setState(() {
        output.sort((a, b) {
          var qtyA = a["qty"] as int;
          var qtyTapA = a["qty_tap"] as int;
          var qtyB = b["qty"] as int;
          var qtyTapB = b["qty_tap"] as int;

          if (qtyTapA < qtyA && qtyTapB < qtyB) {
            return qtyTapA.compareTo(qtyTapB);
          } else if (qtyTapA < qtyA) {
            return -1; // "a" comes first
          } else if (qtyTapB < qtyB) {
            return 1; // "b" comes first
          } else {
            return qtyA.compareTo(qtyB);
          }
        });
      });
    }

    for (var currentItem in output) {
      bool quantitiesMatch = currentItem['qty_tap'] == currentItem['qty'];

      if (quantitiesMatch) {
        matchingQuantities += currentItem['qty_tap'] as int;
      }

      if (matchingQuantities == totalBarangHarusDiTap) {
        for (var element in ctl.listSJ) {
          final data = {
            "nomor_order": element['nomor_order'],
            "nama_toko": element['toko'],
            "creator": username,
            "status": "unvalidasi",
            "customer_nama": "DUMMY",
            "customer_notelp": "DUMMY",
            "supir": username,
            "tapper": username
          };
          DatabaseHelper.instance.insertHistorySuratJalan(data).then((value) =>
              {
                _postRequestSJDone(element['nomor_order']),
                SJDalamPengiriman("2")
              });
        }
      }
    }
  }

  Future SJDalamPengiriman(String statusval) async {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    final url =
        Uri.parse(kURL_ORIGIN + 'pengiriman/update-pengiriman-from-mobile');
    final sj = ctl.noSuratJalanSelected.value.toString().replaceAll(' ', '');
    Map<String, dynamic> requestBody = {
      "sj": "'" + sj + "'",
      "status": statusval
    };

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

  Future<List<bool>> fetchCompletionStatuses() async {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    List<bool> completionStatuses = [];

    for (var i = 0; i < ctl.listInv.length; i++) {
      var e = await ctl.detectCompletionItem(
          ctl.listInv[i]['no_order'], ctl.listInv[i]['inventory_id']);
      completionStatuses.add(e);
    }
    return completionStatuses;
  }

  String stringCensor(String inputString) {
    var prefix = inputString.substring(0, 5);

    var suffix = inputString.substring(inputString.length - 4);

    var outputString = "$prefix*********$suffix";

    return outputString;
  }

  void _launchMapsUrl(List listLoc) async {
    String destUrl = '';
    for (var i = 0; i < listLoc.length; i++) {
      if (i == 0) {
        destUrl += latitude.toString() + ',' + longitude.toString() + '/';
      }
      destUrl += listLoc[i]['dest_loc_latitude'] +
          ',' +
          listLoc[i]['dest_loc_longitude'] +
          '/';
    }

    final url = 'https://www.google.com/maps/dir/${destUrl}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _addLokasiFirebaseFromLok(Position currentPosition) async {
    DateTime timestamp = DateTime.now();

    String curTimeStamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);

    var uuid = Uuid();
    String username = await SharedToken.univGetterString('username');
    username = username.replaceAll(' ', '_');
    String timestampLink = DateFormat('dd-MM-yyyy').format(timestamp);

    // final String userId = username.toString() + '_' + uuid.v4().toString();
    final DatabaseReference dblokRef =
        FirebaseDatabase.instance.ref('sima_pengiriman_supir');

    // final String username = await SharedToken.univGetterString('username');

    final DatabaseReference livelokRef = FirebaseDatabase.instance
        .ref('perjalanan_supir_${username}_${timestampLink}');
    final MapsViewController ctl = Get.put(MapsViewController());
    try {
      final liveLokRefData = ctl.liveLokRefData;
      double latSource = ctl.liveLokRefData['lat_source'] as double;
      double longSource = ctl.liveLokRefData['long_source'] as double;

      double destLatSource = ctl.liveLokRefData['lat_dest'] as double;
      double destLongSource = ctl.liveLokRefData['long_dest'] as double;

      liveLokRefData['lat_cur'] = currentPosition.latitude;
      liveLokRefData['long_cur'] = currentPosition.longitude;
      liveLokRefData['updated_at'] = curTimeStamp;

      // await livelokRef.set(liveLokRefData);

      await dblokRef.push().set({
        'created_at': curTimeStamp,
        'supir': username,
        'cur_long': currentPosition.longitude,
        'cur_lat': currentPosition.latitude,
        'id': uuid.v4()
      });

      // BODY PERJALANAN SUPIR FORMAT : perjalanan_supir_nama_HARI-TANGGAL-BULAN-TAHUN
      // "perjalanan_supir_sima": {
      //   "lat_cur": -6.9466,
      //   "lat_dest": "",
      //   "lat_source": -6.9465,
      //   "long_cur": 107.7299,
      //   "long_dest": "",
      //   "long_source": ""
      // },

      // FIREBASE BUAT DASHBOARD
      // final DatabaseReference dashboardLive =
      //     FirebaseDatabase.instance.ref('realtime_supir_dashboard/${username}');

      // await dashboardLive.set({
      //   "lat": currentPosition.latitude.toString(),
      //   "long": currentPosition.longitude.toString()
      // });

      final DatabaseReference dashboardLive =
          FirebaseDatabase.instance.ref('realtime_supir_dashboard');

      await dashboardLive.set({
        "${username}": {
          "lat": currentPosition.latitude.toString(),
          "long": currentPosition.longitude.toString()
        }
      });
      //FIREBASE BUAT DASHBOARD
      print('User added successfully!');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());
    TextEditingController _textController = TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
            title: Text(
          "Turun Barang (Online)",
          style: TextStyle(
            color: Colors.black,
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

                            if (output[index]['qty_tap'] ==
                                output[index]['qty']) {
                              return ListTile(
                                title: Text(
                                  '${output[index]['product_name']}',
                                  style: TextStyle(color: Colors.green),
                                ),
                                trailing: Text(
                                  '${output[index]['qty_tap']}/${output[index]['qty']}',
                                  style: TextStyle(color: Colors.green),
                                ),
                              );
                            }

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
                                  Text(stringCensor(item)),
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
                  child: Column(
                    children: [
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      textController.text.isNotEmpty &&
                                              !sjDibatalkan
                                          ? Colors.blue
                                          : Colors.blue[200]),
                              onPressed: () async {
                                if (textController.text.isNotEmpty &&
                                    !sjDibatalkan) {
                                  SJDalamPengiriman("17");
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UniversalScannerSCreen(
                                              goBackRouteName:
                                                  TurunBarangOnlineScreen
                                                      .routeName),
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: ctl.barangTap.value == 0
                                ? Colors.red
                                : Colors.red[200], // Background color
                            onPrimary: Colors.white, // Text color
                            elevation: 5, // Elevation (shadow)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  25), // Button border radius
                            ),
                          ),
                          onPressed: () {
                            // Show dialog when the button is pressed
                            if (ctl.barangTap.value == 0) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('SJ Pending Kirim'),
                                    content: Text(
                                        'Sebutkan Alasan untuk SJ ${ctl.nomorSJ} Pending'),
                                    actions: <Widget>[
                                      TextFormField(
                                        controller:
                                            ctl.alasanBataltextController,
                                        maxLines: 10,
                                      ),
                                      TextButton(
                                          onPressed: () async {
                                            await ctl.SJBatalKirim();
                                            if (mounted) {
                                              setState(() {
                                                sjDibatalkan = true;
                                              });
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: Text('Ok'))
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Batal/Gagal Kirim'),
                        ),
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _launchMapsUrl(ctl.listLoc);
                              return;
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: Text('Buka Maps',
                                style: TextStyle(color: Colors.white)),
                          ))
                    ],
                  ),
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
