import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared_preferences/shared_token.dart';
import 'dart:math';

import '../../menu_select_customer/controllers/menu_select_customer_controller.dart';

class TurunBarangOnlineController extends GetxController {
  RxList<dynamic> listSJ = [].obs;
  RxList<dynamic> listSelected = [].obs;
  RxList<dynamic> listInv = [].obs;
  RxString tapper = "".obs;
  RxString nomorSJ = "".obs;
  RxMap<String, dynamic> coordinate = {'lat': '', 'long': ''}.obs;
  RxMap<String, dynamic> suratJalanCredential =
      {'nama_toko': '', 'no_surat_jalan': ''}.obs;
  RxList<dynamic> listLoc = [
    {'': ''}
  ].obs;

  RxInt barangTap = 0.obs;
  RxInt barangHarusTap = 0.obs;

  RxBool hasPriority = false.obs;

  final TextEditingController alasanBataltextController =
      TextEditingController();

  void getListItems(List<dynamic> items) {
    // List mergedItems = items.map((item) => item['items']).toList();
    for (var i = 0; i < items.length; i++) {
      if (items[i]['items'] != null) {
        listInv.addAll(jsonDecode(items[i]['items']));
      }
    }
  }

  Future<dynamic> insertDataTurun(Map<String, dynamic> data) async {
    try {
      var dataInsert = data;
      dataInsert['lat'] = coordinate['lat'];
      dataInsert['long'] = coordinate['long'];
      final tapper = await SharedToken.univGetterString('username');
      dataInsert['tapper'] = tapper;

      await DatabaseHelper.instance.insertBarangTurun(data);
      barangTap.value = barangTap.value + 1;
    } catch (e) {
      print('ERROR $e');
      return e;
    }
  }

  Future<dynamic> detectCompletionItem(
      dynamic noOrder, dynamic inventoryId) async {
    try {
      final e = await DatabaseHelper.instance
          .doesDataExistPerItemTap(noOrder, inventoryId);

      return e;
    } catch (e) {
      print('ERROR $e');

      return e;
    }
  }

  RxString noSuratJalanSelected = "".obs;
  RxList listBarangPrioritas = [].obs;

  var latlongSJ = {}.obs;
  Future<void> getItemsByNoSJ(dynamic listNoSJ) async {
    print('saya disini');
    print(listNoSJ);
    listSJ.clear();
    String noSj = '';

    for (var element in listNoSJ) {
      // long: 107.5895573, lat: -6.8256386,
      latlongSJ['lat_sj'] = element['lat'];
      latlongSJ['long_sj'] = element['long'];

      nomorSJ.value = element['nomor_order'];
      final item = {
        'nomor_order': element['nomor_order'],
        'toko': element['customer_nama']
      };
      listSJ.add(item);
    }
    noSuratJalanSelected.value = listSJ[0]['nomor_order'];

    for (var element in listNoSJ) {
      final item = jsonEncode(element['nomor_order']);
      noSj += item + ',';
    }
    var urli = '${kURL_ORIGIN}sale-wholesale/get-print-sj-data?no_sj=$noSj';

    urli = urli.replaceFirst(RegExp(r',\s*$'), '');

    urli = urli.replaceAll(' ', '');

    var url = Uri.parse(urli);

    var requestBody = {
      'key1': 'value1',
      'key2': 'value2',
    };

    var bodyJson = jsonEncode(requestBody);

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: bodyJson,
      );

      if (response.statusCode == 200) {
        var resp = jsonDecode(response.body);
        listInv.addAll(resp['content']);

        final cntmusTap = resp['content'] as List;
        final cntTapped = resp['content2'] as List;

        barangHarusTap.value = cntmusTap.length;
        barangTap.value = cntTapped.length;

        final barangPriorias = resp['barang_prioritas'] as List;
        if (barangPriorias.isNotEmpty) {
          hasPriority.value = true;
          listBarangPrioritas.addAll(barangPriorias);
        }

        for (var element in resp['content2']) {
          await DatabaseHelper.instance.insertBarangTurun(element);
        }
        Set<Map<String, dynamic>> uniqueLocations = Set<Map<String, dynamic>>();

        for (var item in resp['content']) {
          Map<String, dynamic> locationMap = {
            "dest_loc_name": item['dest_loc_name'],
            "dest_loc_latitude": item['dest_loc_latitude'],
            "dest_loc_longitude": item['dest_loc_longitude'],
          };

          uniqueLocations.add(locationMap);
        }

        // Convert uniqueLocations set back to a list if needed
        List<Map<String, dynamic>> uniqueLocationsList =
            uniqueLocations.toList();
        listLoc.clear();
        // Print the unique combinations
        uniqueLocationsList.forEach((location) {
          bool push = true;
          for (var it in listLoc) {
            if (location['dest_loc_name'] == it['dest_loc_name']) {
              push = false;
              // skip this iteraton
              break;
            } else {
              push = true;
            }
          }
          if (push) {
            if (location['dest_loc_name'] != null ||
                location['dest_loc_latitude'] != null ||
                location['dest_loc_longitude'] != null) {
              Map<String, String> locationMap = {
                "dest_loc_name": location['dest_loc_name'].toString(),
                "dest_loc_latitude": location['dest_loc_latitude'].toString(),
                "dest_loc_longitude": location['dest_loc_longitude'].toString(),
              };
              listLoc.add(locationMap);
            }
          }
        });

        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        double cur_latitude = position.latitude;
        double cur_longitude = position.longitude;

        // setState((){

        //   });

        for (int i = 0; i < listLoc.length; i++) {
          var item = listLoc[i];
          // double dest_latitude = double.parse(item['dest_loc_latitude']);
          // double dest_longitude = double.parse(item['dest_loc_longitude']);
          double dest_latitude =
              double.tryParse(item['dest_loc_latitude'] ?? '') ?? 0.0;
          double dest_longitude =
              double.tryParse(item['dest_loc_longitude'] ?? '') ?? 0.0;
          final distanceKm = haversine(
              cur_latitude, cur_longitude, dest_latitude, dest_longitude);
          listLoc[i]['dest_calc'] = distanceKm.toStringAsFixed(2);

          listLoc[i]['lat_sj'] = latlongSJ['lat_sj'];
          listLoc[i]['long_sj'] = latlongSJ['long_sj'];
        }
        // listLoc.sort((a, b) =>
        //     (a['dest_calc'] as double).compareTo(b['dest_calc'] as double));

        listLoc.sort((a, b) {
          double aDestCalc = double.tryParse(a['dest_calc'] ?? '') ?? 0.0;
          double bDestCalc = double.tryParse(b['dest_calc'] ?? '') ?? 0.0;
          return aDestCalc.compareTo(bDestCalc);
        });
        print(listLoc);
      } else {
        print('POST request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error get item by no SJ: $e');
    }
  }

  Future<void> getItemsByNoSJStr(dynamic noSj) async {
    print('saya disini w');

    // print(listNoSJ);
    listSJ.clear();
    // String noSj = ;

    // for (var element in listNoSJ) {
    //   // long: 107.5895573, lat: -6.8256386,
    //   latlongSJ['lat_sj'] = element['lat'];
    //   latlongSJ['long_sj'] = element['long'];

    //   nomorSJ.value = element['nomor_order'];
    //   final item = {
    //     'nomor_order': element['nomor_order'],
    //     'toko': element['customer_nama']
    //   };
    //   listSJ.add(item);
    // }
    noSuratJalanSelected.value = noSj;

    // for (var element in listNoSJ) {
    //   final item = jsonEncode(element['nomor_order']);
    //   noSj += item + ',';
    // }
    var urli = '${kURL_ORIGIN}sale-wholesale/get-print-sj-data?no_sj=$noSj';

    urli = urli.replaceFirst(RegExp(r',\s*$'), '');

    urli = urli.replaceAll(' ', '');

    var url = Uri.parse(urli);

    var requestBody = {
      'key1': 'value1',
      'key2': 'value2',
    };

    var bodyJson = jsonEncode(requestBody);

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: bodyJson,
      );

      if (response.statusCode == 200) {
        var resp = jsonDecode(response.body);
        listInv.addAll(resp['content']);

        final cntmusTap = resp['content'] as List;
        final cntTapped = resp['content2'] as List;

        barangHarusTap.value = cntmusTap.length;
        barangTap.value = cntTapped.length;

        final barangPriorias = resp['barang_prioritas'] as List;
        if (barangPriorias.isNotEmpty) {
          hasPriority.value = true;
          listBarangPrioritas.addAll(barangPriorias);
        }

        for (var element in resp['content2']) {
          await DatabaseHelper.instance.insertBarangTurun(element);
        }
        Set<Map<String, dynamic>> uniqueLocations = Set<Map<String, dynamic>>();
      } else {
        print('POST request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error get item by no SJ: $e');
    }
  }

  Future SJDalamPengiriman() async {
    final url =
        Uri.parse(kURL_ORIGIN + 'pengiriman/update-pengiriman-from-mobile');
    Map<String, dynamic> requestBody = {
      "sn": "'" + noSuratJalanSelected.value + "'",
      "status": 17
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

  Future SJBatalKirim(BuildContext context) async {
    final username = await SharedToken.univGetterString('username');

    MenuSelectCustomerController ctk = Get.put(MenuSelectCustomerController());

    if (!ctk.internetConnected.value) {
      await DatabaseHelper.instance.insertDataSjBatalKirim(
          nomorSJ.value, alasanBataltextController.text, username);
      showSuccessMessage(context, 'Berhasil!');
      return;
    }

    final url =
        Uri.parse(kURL_ORIGIN + 'pengiriman/mobile-pending-batal-kirim');

    Map<String, dynamic> requestBody = {
      "no_surat_jalan": nomorSJ.value,
      "alasan": alasanBataltextController.text,
      "creator": username
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        showSuccessMessage(context, 'Berhasil!');

        print('POST request successful! Response:');
        print(response.body);
        // await DatabaseHelper.instance.insertHistorySuratJalanBatal(requestBody);
        // await DatabaseHelper.instance
        //     .deleteRecordTugasByNomorOrder(nomorSJ.value);
      } else {
        print('POST request failed with status: ${response.statusCode}');
        print(response.body);
      }
      alasanBataltextController.text = '';
    } catch (error) {
      print('Error making POST request: $error');
    }
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    // Convert latitude and longitude from degrees to radians
    lat1 = degreesToRadians(lat1);
    lon1 = degreesToRadians(lon1);
    lat2 = degreesToRadians(lat2);
    lon2 = degreesToRadians(lon2);

    var dlat = lat2 - lat1;
    var dlon = lon2 - lon1;
    var a =
        pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Radius of Earth in kilometers (mean value)
    var R = 6371.0;

    // Calculate the distance
    var distance = R * c;

    return distance;
  }
}
