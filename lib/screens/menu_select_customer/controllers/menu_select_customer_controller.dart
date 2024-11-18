import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';

import '../../../constants.dart';
import '../../../shared_preferences/shared_token.dart';
import '../../order_service/controll.ers/order_service_controller.dart';
// import 'package:sima_pengiriman/screens/menu_select_customer/models/customer_model_offline.dart';

class MenuSelectCustomerController extends GetxController {
  var internetConnected = false.obs;
  var isLoading = true.obs;

  void syncApp(BuildContext context) async {
    try {
      isLoading.value = true;

      OverlayLoadingProgress.start(
          widget: Container(
              color: Colors.white,
              height: 100,
              width: 100,
              child: Builder(
                builder: (context) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(
                          'Fetching...',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(
                                fontSize: 16, // Adjust the font size if needed
                                fontWeight: FontWeight
                                    .bold, // Make it bold for emphasis
                                color:
                                    Colors.black, // You can customize the color
                                decoration:
                                    TextDecoration.none, // Remove underline
                              ),
                        ),
                      ],
                    ),
                  );
                },
              )));

      if (internetConnected.value) {
        await syncOrderTitipan(context);

        final dailyReport =
            await DatabaseHelper.instance.getDailyReportSupirToday();

        //  [{id: 1, liter: , km: 10, tipe: LAPORAN_KM, attachment: /data/user/0/com.example.sima_pengiriman/cache/1cd8d8d4-9f66-4b5e-bda6-1f58e8739a9c/1000000138.png, tipe_attachment: indikator_bensin, keterangan: aaa, username: Faisal Supir, plat_no: D FGH, latitude: -6.9484183, longitude: 107.63315, date_added: 2024-11-10}]

        for (var i = 0; i < dailyReport.length; i++) {
          var item = dailyReport[i];
          Map<String, String> listImgs = {
            item['tipe_attachment']: item['attachment']
          };

          if (!context.mounted) return;

          await uploadReport(
            context: context,
            dropdownValue: item['tipe'],
            listImgs: listImgs,
            username: item['username'],
            keteranganTextController: item['keterangan'],
            kmTextController: item['km'],
            literTextController: item['liter'],
            platNo: item['plat_no'],
            latitude: item['latitude'],
            longitude: item['longitude'],
          );

          await DatabaseHelper.instance.deleteDailyReportById(item['id']);
        }
      }
      if (!context.mounted) return;

      await syncSNData(context);

      final scannedSnData = await DatabaseHelper.instance.getLastScannedSn();
      for (var item in scannedSnData) {
        await DatabaseHelper.instance.removeScannedSn(item['sn']);
        await Future.delayed(const Duration(seconds: 1));
      }
      await Future.delayed(const Duration(seconds: 3));
      OverlayLoadingProgress.stop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error : $e')),
      );
    }
  }

  Future<void> uploadReport({
    required String dropdownValue,
    required String username,
    required String kmTextController,
    required String literTextController,
    required String platNo,
    required String latitude,
    required String longitude,
    required String keteranganTextController,
    required Map<String, String?> listImgs,
    required BuildContext context,
  }) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${kURL_ORIGIN}pengiriman/supir-upload-report?tipe=$dropdownValue&username=$username&km=${kmTextController}&liter=${literTextController}&plat_no=$platNo&keterangan=${keteranganTextController}&lat=${latitude}&long=${longitude}'));

    // Add files if they exist
    if (listImgs['foto_struck'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'foto_struck', listImgs['foto_struck']!));
    }
    if (listImgs['indikator_bensin'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'indikator_bensin', listImgs['indikator_bensin']!));
    }
    if (listImgs['km_kendaraan'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'km_kendaraan', listImgs['km_kendaraan']!));
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (response.statusCode == 200) {
        print('Files uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${responseBody}')),
        );
      } else {
        print('File upload failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed: ${responseBody}')),
        );
      }
    } catch (e) {
      print('Error uploading files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading files: $e')),
      );
    }
  }

  Future<void> syncOrderTitipan(BuildContext context) async {
    List<Map<dynamic, dynamic>> result =
        await DatabaseHelper.instance.getOrderServices();
    final OrderServiceController ctk = Get.put(OrderServiceController());
    print(result);
    for (var item in result) {
      // var tokoId = item['toko_id'];

      // var request = http.Request('POST',
      //     Uri.parse('${kURL_ORIGIN}supir-get-toko-by-id?toko_id=$tokoId'));

      // http.StreamedResponse response = await request.send();

      // if (response.statusCode == 200) {
      //   var resp = await response.stream.bytesToString();

      // var jsonResponse = jsonDecode(resp);

      // if (!jsonResponse['success']) {
      //   if (!context.mounted) return;

      //   // Handle failure by showing a SnackBar
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('${jsonResponse['msg']}'),
      //       action: SnackBarAction(
      //         label: 'Undo',
      //         onPressed: () {
      //           // Code to execute when "Undo" is pressed
      //           print('Undo action pressed!');
      //         },
      //       ),
      //     ),
      //   );
      //   return;
      // }

      // var toko = jsonResponse['result'];
      // if (jsonResponse['result'] == []) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('An error occurred. Please try again.')),
      //   );
      //   return;
      // }

      // var swcId = toko['swc_id'];

      // var address = toko['swc_address'];

      // var customerName = '${toko['swc_shop_name']} (${toko['swc_fullname']})';

      List<Map<dynamic, dynamic>> imgsAttachment =
          await DatabaseHelper.instance.getOrderServicesAttachment(item['id']);

      List<File> imageList = [];
      for (var att in imgsAttachment) {
        imageList.add(File(att['path']));
      }

      final username = await SharedToken.univGetterString('username');
      final platNo = await SharedToken.univGetterString('no_plat');
      final apiUrl =
          // ignore: unnecessary_brace_in_string_interps
          '${kURL_ORIGIN}supir-titip-service?keterangan=${item['keterangan']}&username=$username&location_id=${item['location_id']}&plat_no=${platNo}&barang_tidak_muat=${item['tidak_muat']}&customer_id=${item['customer_id']}';

      List<Map<dynamic, dynamic>> listSn =
          await DatabaseHelper.instance.getOrderServicesSN(item['id']);

      final dataToSend = listSn.map((item3) {
        return {'sn': item3['sn'], 'product_id': item3['product_id']};
      }).toList();

      final dataSend = jsonEncode(dataToSend);

      print(apiUrl);

      await ctk.uploadImagesAndFormData(
          imageList, {'data_send': dataSend}, apiUrl);
      // }
      await DatabaseHelper.instance.deleteOrderService(item['id']);
    }
  }

  // TABLE NOT EXIST WHY I MADE THIS??
  Future<void> syncSupirUploadAttachmentTask(BuildContext context) async {
    List<Map<String, dynamic>> data =
        await DatabaseHelper.instance.getSupirUploadAttachmentTask();
    String uname = await SharedToken.univGetterString('username');
    final platNo = await SharedToken.univGetterString('no_plat');
    if (!context.mounted) return;
    print(data);

    // print('aaaaaaa');
    for (var item in data) {
      if (!context.mounted) return;

      await uploadFile(
          context: context,
          uname: uname,
          platNo: platNo,
          keteranganTxt: item['keterangan'],
          latitude: item['latitude'],
          longitude: item['longitude'],
          noSuratJalanSelected: item['nomor_order'],
          selectedImg: File(item['file']));
      String res =
          await DatabaseHelper.instance.deleteSupirAttachmentById(item['id']);

      if (res != 'SUKSES') {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File upload failed : ${res}'),
          ),
        );
      }
    }
  }

  Future<void> uploadFile({
    required String noSuratJalanSelected,
    required String uname,
    required String keteranganTxt,
    required String platNo,
    required String latitude,
    required String longitude,
    required File selectedImg,
    required BuildContext context,
  }) async {
    var url = Uri.parse(
        '${kURL_ORIGIN}pengiriman/supir-upload-attachment-task?nomor_order=$noSuratJalanSelected&username=$uname&keterangan=$keteranganTxt&plat_no=$platNo&lat=${latitude}&long=${longitude}');

    var request = http.MultipartRequest('POST', url);

    var fileStream = http.ByteStream(selectedImg.openRead());
    var length = await selectedImg.length();
    var multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: selectedImg.path,
    );

    request.files.add(multipartFile);

    var response = await request.send();

    // Handle the response
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('File upload failed with status: ${response.statusCode}'),
        ),
      );
    }
  }

  syncSNData(BuildContext context) async {
    final dataSN = await DatabaseHelper.instance.getLastScannedSn();

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=h5atvnk8jg9ikejkskh0sguc2b'
    };
    var request = http.Request('POST', Uri.parse('${kURL_ORIGIN}sync-sn'));
    request.body = json.encode({"scanned_sn": jsonEncode(dataSN)});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response.statusCode}, ${jsonResponse['msg']}'),
        ),
      );

      // print(jsonResponse); // Handle the JSON response here
    } else {
      // print(response.reasonPhrase);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response.statusCode}, ${response.reasonPhrase}'),
        ),
      );
    }
  }
}
