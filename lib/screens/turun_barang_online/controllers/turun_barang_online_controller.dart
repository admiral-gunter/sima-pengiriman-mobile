import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../../../shared_preferences/shared_token.dart';

class TurunBarangOnlineController extends GetxController {
  RxList<dynamic> listSJ = [].obs;
  RxList<dynamic> listSelected = [].obs;
  RxList<dynamic> listInv = [].obs;
  RxString tapper = "".obs;
  RxString nomorSJ = "".obs;
  RxMap<String, dynamic> coordinate = {'lat': '', 'long': ''}.obs;
  RxMap<String, dynamic> suratJalanCredential =
      {'nama_toko': '', 'no_surat_jalan': ''}.obs;

  RxInt barangTap = 0.obs;
  RxInt barangHarusTap = 0.obs;

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
  Future<void> getItemsByNoSJ(dynamic listNoSJ) async {
    listSJ.clear();
    String noSj = '';

    for (var element in listNoSJ) {
      nomorSJ.value = element['nomor_order'];
      final item = {
        'nomor_order': element['nomor_order'],
        'toko': element['customer_nama']
      };
      listSJ.add(item);
    }
    print('List SJ ${listSJ}');
    noSuratJalanSelected.value = listSJ[0]['nomor_order'];

    for (var element in listNoSJ) {
      final item = jsonEncode(element['nomor_order']);
      noSj += item + ',';
    }
    var urli = kURL_ORIGIN + 'sale-wholesale/get-print-sj-data?no_sj=' + noSj;

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

        for (var element in resp['content2']) {
          await DatabaseHelper.instance.insertBarangTurun(element);
        }
        print(
            'barang Tap = ${barangHarusTap.value} \n tapped ${barangTap.value}');
      } else {
        print('POST request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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

  Future SJBatalKirim() async {
    final url =
        Uri.parse(kURL_ORIGIN + 'pengiriman/mobile-pending-batal-kirim');
    final username = await SharedToken.univGetterString('username');
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
}
