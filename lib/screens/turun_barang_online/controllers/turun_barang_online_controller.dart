import 'dart:convert';

import 'package:get/get.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:http/http.dart' as http;

class TurunBarangOnlineController extends GetxController {
  RxList<dynamic> listSJ = [].obs;

  RxList<dynamic> listSelected = [].obs;
  RxList<dynamic> listInv = [].obs;
  RxString tapper = "".obs;

  RxMap<String, dynamic> coordinate = {'lat': '', 'long': ''}.obs;

  RxMap<String, dynamic> suratJalanCredential =
      {'nama_toko': '', 'no_surat_jalan': ''}.obs;
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
      // data['lat'] = coordinate['lat'];
      // data['long'] = coordinate['long'];
      var dataInsert = data;
      dataInsert['lat'] = coordinate['lat'];
      dataInsert['long'] = coordinate['long'];
      dataInsert['tapper'] = tapper.value;
      await DatabaseHelper.instance.insertBarangTurun(data);
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

  Future<void> getItemsByNoSJ(dynamic listNoSJ) async {
    String noSj = '';

    for (var element in listNoSJ) {
      // final item = jsonEncode(element['nomor_order']);
      // noSj += item + ',';
      final item = {
        'nomor_order': element['nomor_order'],
        'toko': element['customer_nama']
      };
      listSJ.add(item);
    }

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
        print('POST request successful $urli');
        var resp = jsonDecode(response.body);
        // print(resp['content']);
        listInv.addAll(resp['content']);
        // print('Response body: ${response.body}');
      } else {
        print('POST request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
