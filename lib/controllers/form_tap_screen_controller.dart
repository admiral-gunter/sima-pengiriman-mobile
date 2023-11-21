import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sima_pengiriman/controllers/list_po_controller.dart';
import '../constants.dart';
import '../shared_preferences/shared_token.dart';

import 'dart:io';

class FormTapScreenController extends GetxController {
  RxList<dynamic> listLokasi = <dynamic>[].obs;
  RxList<String> listPo = <String>[].obs;
  RxList dataPurchaseOrderDetail = [].obs;
  RxString notes = ''.obs;
  RxString kodeBT = ''.obs;
  var btm = {}.obs;

  RxInt lokasiSelect = 0.obs;
  // @override
  // Future onInit() async {
  //   print('Widget created!');
  //   await getlistLokasi();
  //   super.onInit();
  // }

  void chgLokasi(dynamic prop) {
    lokasiSelect.value = prop;
    update();
  }

  void setNotes(String prop) {
    notes.value = prop;
    // update();
  }

  String convertToQueryString(List<String> poList) {
    List<String> queryParameters = [];

    for (int i = 0; i < poList.length; i++) {
      String param = "id[$i]=${Uri.encodeQueryComponent("'${poList[i]}'")}";
      queryParameters.add(param);
    }

    return queryParameters.join('&');
  }

  Future getlistLokasi() async {
    try {
      final token = await SharedToken.tokenGetter();
      final companyId = await SharedToken.companyGetter();
      listLokasi.clear();

      var param = '?field=select2_gudang&tipe=1';
      var url = Uri.parse(
          kURL_ORIGIN + 'select2/get-raw/' + companyId + '/' + token! + param);

      var response = await http.post(url);

      var res = jsonDecode(response.body);

      listLokasi.addAll(res);
      update();
    } catch (e) {
      print('Error sending POST request: $e');
    }
  }

  RxString queryStringPo = ''.obs;

  Future<dynamic> myFunction() async {
    dataPurchaseOrderDetail.clear();
    var listbChecked = Get.find<ListPoController>()
        .listBt
        .where((item) => item[6] == 1)
        .toList();
    List<String>? po;
    po = listbChecked.map((item) => item[0]).cast<String>().toList();
    print('${po} EIN PO');

    // Web API endpoint URLs
    final apiHost = kURL_ORIGIN; // Replace with your actual API host URL
    final company =
        await SharedToken.companyGetter(); // Replace with the company ID
    final token = await SharedToken
        .tokenGetter(); // Replace with your authentication token

    // Helper function to make GET requests
    Future<Map<String, dynamic>> getRequest(String endpoint) async {
      final response = await http.get(Uri.parse(endpoint));
      return json.decode(response.body);
    }

    // Helper function to make POST requests
    Future<Map<String, dynamic>> postRequest(String endpoint,
        {Map<String, String>? data}) async {
      final response = await http.post(Uri.parse(endpoint), body: data);
      return json.decode(response.body);
    }

    /*
    ===========
    RENDER CODE
    ===========
  */
    // Get data company by ID
    final url = '${apiHost}company/get-by-id/$company/$token';
    final req = await getRequest(url);
    final dataCompany = req['content'];

    // Get company code
    String companyCode = 'GM';
    if (dataCompany != null && dataCompany.isNotEmpty) {
      companyCode = dataCompany[0]['company_code'];
    }
    var btgroup = '';
    // Grouping Purchase Order
    if (DateTime.now().month < 10) {
      btgroup =
          'BT$companyCode${DateTime.now().year}0${DateTime.now().month}${DateTime.now().day}';
    } else {
      btgroup =
          'BT$companyCode${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}';
    }

    // Get list purchase order by pogroup
    final url2 =
        '${apiHost}inventory-receipt/get-by-group/$company/$token?:ongroup=${btgroup}';
    // final options = {':ongroup': btgroup};
    final req2 = await postRequest(url2);
    int i = req2['content']?.length ?? 0;

    i = i + 3;

    var kdeBT = '';

    if (DateTime.now().month < 10) {
      kdeBT =
          'BT$companyCode${DateTime.now().year}0${DateTime.now().month}${DateTime.now().day}${i.toString().padLeft(4, '0')}';
    } else {
      kdeBT =
          'BT$companyCode${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${i.toString().padLeft(4, '0')}';
    }

    if (kodeBT.value == '' || kodeBT.value.isEmpty) {
      kodeBT.value = kdeBT;
    }

    // return;
    /*
      ==================
      INVENTORY LOCATION
      ==================
    */
    // Get inventory location by company id
    final url3 = '${apiHost}inventory-location/get-raw/$company/$token';
    final req3 = await getRequest(url3);
    final dataLocation = req3['content'];
    // debugPrint('LOKDAT ${dataLocation}');

    /*
      ==============
      PURCHASE ORDER
      ==============
    */
    // final response = await http.post(Uri.parse(url4), body: options2);
    // debugPrint('${response.body}');

    final pores = convertToQueryString(po);

    final url4 = '${apiHost}purchase-order-detail/get-by-po-id-bulk/$token?';
    // print('${pores}');
    // return;
    final lokasi = await SharedToken.univGetterString('lokasi');
    print('${url4}${pores}&location_id=${lokasi} rill');
    final response =
        await http.post(Uri.parse('${url4}${pores}&location_id=${lokasi}'));
    var dataPo = {};
    // print('${response.body}');

    List<String> list_po = [];
    Map<int, Map<String, dynamic>> list_btm = {};
    Map<int, Map<int, String>> list_detail_btm = {};

    List<int> list_product_id = [];
    List<String> list_identifier_kodeunik = [];
    List<String> list_identifier_kodeunik2 = [];
    int qty_total = 0;
    List<int> digit_penanda_message = [];
    bool is_same_digit_penanda = false;
    List list_identifier_po = [];

    if (dataPurchaseOrderDetail.isNotEmpty) {
      for (var row in dataPurchaseOrderDetail) {
        list_po[row.purchase_order_id] = 'done';
        list_btm[row.purchase_order_id] = {
          'btm': '',
          'po_id': row.purchase_order_id
        };
        if (list_detail_btm[row.purchase_order_id] == null) {
          list_detail_btm[row.purchase_order_id] = {};
        }
        list_detail_btm[row.purchase_order_id]![row.product_id] = '';
        list_identifier_po.add({
          'identifier': row.product_identifier,
          'po': row.purchase_order_id,
          'qty_total': row.qty_req - row.qty_receive,
          'qty_terima': 0,
          'product_id': row.product_id,
          'po_detail_id': row.id,
          'tipe': row.tipe,
          'product_name': row.product_name,
          'penanda': row.digit_penanda,
          'syarat_penanda': row.digit_penanda2
        });
        list_identifier_kodeunik.add(row.digit_penanda);
        list_identifier_kodeunik2.add(row.digit_penanda2);
        list_product_id.add(row.product_id);
        qty_total += int.parse(row.qty_req);
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    dataPo['bt_group'] = btgroup;
    dataPo['creator'] = await SharedToken.univGetterString('username');
    dataPo['note'] = await SharedToken.univGetterString('notes');
    if (prefs.getBool('submitted') != null ||
        prefs.getBool('submitted') == true) {}
    if (btm['btm_id'] == null || btm['btm_detail_id'] == null) {
      print('BTM HAS NULL OR EMPTY');
      dataPo['tanggal'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    dataPo['penerima'] = await SharedToken.univGetterString('username');
    dataPo['company_id'] = await SharedToken.companyGetter();
    dataPo['inventory_location_id'] =
        await SharedToken.univGetterString('lokasi');

    String queryString = createQueryString(dataPo: dataPo);
    // print(queryString);
    print('${url4}${pores}');
    queryStringPo.value = queryString;

    var re2 = jsonDecode(response.body);
    print('${re2} data ordfer');
    dataPurchaseOrderDetail.addAll(re2['content']);

    return kdeBT;
  }

  Future<void> addTapBarang() async {
    final companyId = await SharedToken.companyGetter();
    final token = await SharedToken.tokenGetter();

    await http.post(
        Uri.parse('inventory-receipt/save-live-bulk/${companyId}/${token}'),
        body: {});
  }

  String createQueryString({dynamic? dataPo, dynamic? detailInv}) {
    List<String> queryParameters = [];

    dataPo?.forEach((key, value) {
      String param =
          "dataPo[${Uri.encodeQueryComponent(key)}]=${Uri.encodeQueryComponent(value.toString())}";
      queryParameters.add(param);
    });

    detailInv?.forEach((key, value) {
      String param =
          "detail_inv[${Uri.encodeQueryComponent(key)}]=${Uri.encodeQueryComponent(value.toString())}";
      queryParameters.add(param);
    });

    return queryParameters.join('&');
  }

  RxString tipe = 'SN'.obs;

  var errorSound = false.obs;

  Map<String, dynamic> detail_inv = {};
  RxString noSN = ''.obs;
  RxString lastStatus = ''.obs;

  Future<String> scanAct(dynamic prop) async {
    List<dynamic> matchingItems = dataPurchaseOrderDetail
        .where((item) => item['product_identifier'] == prop)
        .toList();
    if (matchingItems.length > 0) {
      return 'Identifier';
    } else {
      return 'SN';
    }
    print('${queryStringPo} WADOh');
    if (noSN.value == '') {
      noSN.value = prop;
      detail_inv['serial_number'] = prop;
      print('${noSN.value} WOI');
    } else {
      // DONT UNCOMMENT COMMENT FOR DEBUG ONLY

      final kdeBT = await myFunction();
      List<dynamic> items = dataPurchaseOrderDetail
          .where((item) => item['product_identifier'] == prop)
          .toList();

      bool hasDuplicates = items.length != items.toSet().length;

      bool hasMissingDigitPenanda =
          items.any((item) => item['digit_penanda'] == null);

      if (hasDuplicates) {
        print('Duplicate items found.');
        if (hasMissingDigitPenanda) {
          print('Some items have missing digit_penanda.');

          return 'Ada identifier yang tidak mempunyai digit penanda, silahkan pergi ke product master';
        }
      }

      // DONT UNCOMMENT COMMENT FOR DEBUG ONLY

      List<dynamic> matchingItems = dataPurchaseOrderDetail
          .where((item) => item['product_identifier'] == prop)
          .toList();
      // return jsonEncode(matchingItems);
      if (matchingItems.length > 1) {
        bool hasMissingDigitPenanda =
            matchingItems.any((item) => item['digit_penanda'] == null);
        if (hasMissingDigitPenanda) {
          errorSound.value = true;
          return 'Ada identifier yang tidak mempunyai digit penanda, silahkan pergi ke product master';
        }
      }

      List<dynamic> digitPenandaArray = [];
      bool penanda = false;

      for (var result in matchingItems) {
        print('${matchingItems} waaa');
        if (result['digit_penanda'] != null && result['digit_penanda'] != '') {
          penanda = true;
          if (detail_inv['serial_number'].contains(result['digit_penanda'])) {
            // digitPenandaArray.add(result);
          }
        } else {
          penanda = false;
          // digitPenandaArray.add(result);
        }
        digitPenandaArray.add(result);
      }

      if (digitPenandaArray.length == 0 && penanda) {
        errorSound.value = true;
        return 'SN TIDAK COCOK DENGAN DIGIT PENANDA';
      }

      if (digitPenandaArray.length == 0) {
        errorSound.value = true;
        return 'Salah Nomor Product Identifier';
      }
      print('${jsonEncode(digitPenandaArray)}');
      // Map<String, dynamic>? result = dataPurchaseOrderDetail.firstWhere(
      //   (item) => item['product_identifier'] == prop,
      //   orElse: () => null, // Return null if no matching item is found
      // );
      // var result = null;
      // print(result);
      // return 'null';
      Map<String, dynamic>? result = digitPenandaArray[0];

      if (result != null) {
        if (detail_inv['serial_number'] != null) {
          print('hier i am');
          if (result['qty_total'] == result['qty_receive']) {
            errorSound.value = true;
            return 'Barang Tidak Dapat Disimpan, Quantity Barang Sudah Melebihin Quantity Po';
          }
          var qtyTot = int.parse(result['qty_total']);
          var qtyRec = int.parse(result['qty_receive']);
          // return '${qtyTot} und ${qtyRec}';
          if (qtyRec > qtyTot) {
            errorSound.value = true;
            return 'Barang Tidak Dapat Disimpan, Quantity Barang Sudah Melebihin Quantity Po';
          }
          print('dimana');

          // if (qtyReceive > qtyTotal) {
          //   return 'Barang Tidak Dapat Disimpan, Quantity Barang Sudah Melebihin Quantity Po';
          // }

          tipe.value = 'Identifier';
          // update();
          String digitPenandaAsString = result['digit_penanda'].toString();
          print(digitPenandaAsString);
          // return digitPenandaAsString;
          if (digitPenandaAsString.isNotEmpty &&
              digitPenandaAsString != 'null') {
            print('sayang ${digitPenandaAsString}');

            String serialNum = detail_inv['serial_number'].toString();

            if (!serialNum.contains(digitPenandaAsString)) {
              errorSound.value = true;

              print('kamu');
              return 'SN TIDAK COCOK DENGAN DIGIT PENANDA';
            }
          }
          print('saya');

          // detail_inv['serial_number'] = noSN.value;
          detail_inv['identifier'] = prop;
          detail_inv['product_id'] = result['product_id'];
          detail_inv['po'] = result['purchase_order_id'];
          detail_inv['tipe'] = result['tipe'];
          detail_inv['kode_bt_mb'] = kdeBT;
          detail_inv['mobile'] = 'yes';

          if (btm['btm_id'] != null || btm['btm_detail_id'] != null) {
            print('BTM HAS VALUE');
            detail_inv['btm'] = btm['btm_id'];
            detail_inv['detail_btm'] = btm['btm_detail_id'];
          }

          final companyId = await SharedToken.companyGetter();
          final token = await SharedToken.tokenGetter();

          String queryStringInv = createQueryString(detailInv: detail_inv);

          final url =
              '${kURL_ORIGIN}inventory-receipt/save-live-bulk/${companyId}/${token}?${queryStringPo}&${queryStringInv}';
          print('${url} here');

          try {
            var response = await http.post(Uri.parse(url));

            if (response.statusCode == 200) {
              // Successful response
              var res = jsonDecode(response.body);

              final companyId = await SharedToken.companyGetter();
              final token = await SharedToken.tokenGetter();

              await http.post(
                  Uri.parse(
                      '${kURL_ORIGIN}inventory-receipt/check-po-live-bulk/${companyId}/${token}?po_id=${detail_inv['po']}'),
                  body: {});

              // lastStatus.value = detail_inv['serial_number'];
              lastStatus.value = res['msg'];
              tipe.value = 'SN';
              detail_inv = {};
              noSN.value = '';

              if (res['content'] != '' || res['content'] != null) {
                if (res['content'] is String) {
                } else {
                  btm.value = res['content'];
                }
              }

              if (res['msg'] == 'format serial number salah') {
                errorSound.value = true;
              }

              if (res['msg'] == 'Serial Sudah Pernah ada didata base') {
                errorSound.value = true;
              }
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.setBool("submitted", true);
              await myFunction();

              return res['msg'];
              // Do something with the 'res' data
            } else {
              errorSound.value = true;

              // Handle unsuccessful response (e.g., 404, 500, etc.)
              print('Request failed with status: ${response.statusCode}');
              print('Response body: ${response.body}');

              return 'Request failed with status: ${response.statusCode}';
              // Add further error handling or notify the user accordingly
            }
          } catch (e) {
            errorSound.value = true;

            // Handle exceptions that might occur during the request
            print('Error during HTTP request: $e');
            return 'Error during HTTP request: $e';
            // Add further error handling or notify the user accordingly
          }
        }
      }
    }
    return noSN.value;
  }

  Future<String> scanActV2(dynamic prop) async {
    List<dynamic> matchingItems = dataPurchaseOrderDetail
        .where((item) => item['product_identifier'] == prop)
        .toList();
    if (matchingItems.length > 0) {
      detail_inv['identifier'] = prop;
    } else {
      detail_inv['serial_number'] = prop;
    }

    if (detail_inv['serial_number'] != null &&
        detail_inv['identifier'] != null) {
      matchingItems = dataPurchaseOrderDetail
          .where(
              (item) => item['product_identifier'] == detail_inv['identifier'])
          .toList();
      // DONT UNCOMMENT COMMENT FOR DEBUG ONLY

      final kdeBT = await myFunction();
      List<dynamic> items = dataPurchaseOrderDetail
          .where(
              (item) => item['product_identifier'] == detail_inv['identifier'])
          .toList();
      // return '${jsonEncode(items.length)} list item';

      // bool hasDuplicates = items.length != items.toSet().length;

      bool hasMissingDigitPenanda =
          items.any((item) => item['digit_penanda'] == null);

      if (items.length > 1) {
        print('Duplicate items found.');
        if (hasMissingDigitPenanda) {
          errorSound.value = true;

          print('Some items have missing digit_penanda.');

          return 'Ada identifier yang tidak mempunyai digit penanda, silahkan pergi ke product master';
        }
      }

      // DONT UNCOMMENT COMMENT FOR DEBUG ONLY

      // if (matchingItems.length > 0) {
      //   bool hasMissingDigitPenanda =
      //       matchingItems.any((item) => item['digit_penanda'] == null);
      //   if (hasMissingDigitPenanda) {
      //     errorSound.value = true;
      //     return 'Ada identifier yang tidak mempunyai digit penanda, silahkan pergi ke product master';
      //   }
      // }

      List<dynamic> digitPenandaArray = [];
      bool penanda = false;

      for (var result in matchingItems) {
        print('${matchingItems} waaa');
        if (result['digit_penanda'] != null && result['digit_penanda'] != '') {
          penanda = true;
          if (detail_inv['serial_number'].contains(result['digit_penanda'])) {
            digitPenandaArray.add(result);
          }
        } else {
          digitPenandaArray.add(result);

          penanda = false;
        }
        // digitPenandaArray.add(result);
      }

      if (digitPenandaArray.length == 0 && penanda) {
        errorSound.value = true;
        return 'SN TIDAK COCOK DENGAN DIGIT PENANDA';
      }

      if (digitPenandaArray.length > 1) {
        errorSound.value = true;
        return 'Digit penanda tidak sesuai dengan Serial Number';
      }

      print('${jsonEncode(digitPenandaArray)} DIGITPENANDAARRAY');
      if (digitPenandaArray.length == 0) {
        errorSound.value = true;
        return 'Salah Nomor Product Identifier ';
      }

      Map<String, dynamic>? result = digitPenandaArray[0];

      if (result != null) {
        if (detail_inv['serial_number'] != null) {
          print('hier i am');
          if (result['qty_total'] == result['qty_receive']) {
            errorSound.value = true;
            return 'Barang Tidak Dapat Disimpan, Quantity Barang Sudah Melebihin Quantity Po';
          }
          var qtyTot = int.parse(result['qty_total']);
          var qtyRec = int.parse(result['qty_receive']);
          // return '${qtyTot} und ${qtyRec}';
          if (qtyRec > qtyTot) {
            errorSound.value = true;
            return 'Barang Tidak Dapat Disimpan, Quantity Barang Sudah Melebihin Quantity Po';
          }

          tipe.value = 'Identifier';
          String digitPenandaAsString = result['digit_penanda'].toString();
          print(digitPenandaAsString);
          if (digitPenandaAsString.isNotEmpty &&
              digitPenandaAsString != 'null') {
            print('digit penanda kamu : ${digitPenandaAsString}');

            String serialNum = detail_inv['serial_number'].toString();

            if (!serialNum.contains(digitPenandaAsString)) {
              errorSound.value = true;

              print('kamu');
              return 'SN TIDAK COCOK DENGAN DIGIT PENANDA';
            }
          }
          print('saya');

          // detail_inv['serial_number'] = noSN.value;
          detail_inv['product_id'] = result['product_id'];
          detail_inv['po'] = result['purchase_order_id'];
          detail_inv['tipe'] = result['tipe'];
          detail_inv['kode_bt_mb'] = kdeBT;
          detail_inv['mobile'] = 'yes';

          if (btm['btm_id'] != null || btm['btm_detail_id'] != null) {
            print('BTM HAS VALUE');
            detail_inv['btm'] = btm['btm_id'];
            detail_inv['detail_btm'] = btm['btm_detail_id'];
          }

          final companyId = await SharedToken.companyGetter();
          final token = await SharedToken.tokenGetter();

          String queryStringInv = createQueryString(detailInv: detail_inv);

          final url =
              '${kURL_ORIGIN}inventory-receipt/save-live-bulk/${companyId}/${token}?${queryStringPo}&${queryStringInv}';
          print('${url} here');

          try {
            var response = await http.post(Uri.parse(url));

            if (response.statusCode == 200) {
              // Successful response
              var res = jsonDecode(response.body);

              final companyId = await SharedToken.companyGetter();
              final token = await SharedToken.tokenGetter();

              await http.post(
                  Uri.parse(
                      '${kURL_ORIGIN}inventory-receipt/check-po-live-bulk/${companyId}/${token}?po_id=${detail_inv['po']}'),
                  body: {});

              // lastStatus.value = detail_inv['serial_number'];
              lastStatus.value = res['msg'];
              tipe.value = 'SN';
              detail_inv = {};
              noSN.value = '';

              if (res['content'] != '' || res['content'] != null) {
                if (res['content'] is String) {
                } else {
                  btm.value = res['content'];
                }
              }

              if (res['msg'] == 'format serial number salah') {
                errorSound.value = true;
              }

              if (res['msg'] == 'Serial Sudah Pernah ada didata base') {
                errorSound.value = true;
              }
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.setBool("submitted", true);
              await myFunction();

              return res['msg'];
              // Do something with the 'res' data
            } else {
              errorSound.value = true;

              // Handle unsuccessful response (e.g., 404, 500, etc.)
              print('Request failed with status: ${response.statusCode}');
              print('Response body: ${response.body}');

              return 'Request failed with status: ${response.statusCode}';
              // Add further error handling or notify the user accordingly
            }
          } catch (e) {
            errorSound.value = true;

            // Handle exceptions that might occur during the request
            print('Error during HTTP request: $e');
            return 'Error during HTTP request: $e';
            // Add further error handling or notify the user accordingly
          }
        }
      }
    }

    return prop.toString();
  }

  Future updateStatusPo() async {
    try {
      final companyId = await SharedToken.companyGetter();
      final token = await SharedToken.tokenGetter();

      await http.post(
          Uri.parse(
              'inventory-receipt/check-po-live-bulk/${companyId}/${token}?po_id='),
          body: {});
    } catch (e) {}
  }
}
