import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';

import '../../../constants.dart';
// import 'package:sima_pengiriman/screens/menu_select_customer/models/customer_model_offline.dart';

class MenuSelectCustomerController extends GetxController {
  var internetConnected = false.obs;
  var isLoading = true.obs;

  void syncApp(BuildContext context) async {
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
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              fontSize: 16, // Adjust the font size if needed
                              fontWeight:
                                  FontWeight.bold, // Make it bold for emphasis
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
      final dailyReport =
          await DatabaseHelper.instance.getDailyReportSupirToday();

      //  [{id: 1, liter: , km: 10, tipe: LAPORAN_KM, attachment: /data/user/0/com.example.sima_pengiriman/cache/1cd8d8d4-9f66-4b5e-bda6-1f58e8739a9c/1000000138.png, tipe_attachment: indikator_bensin, keterangan: aaa, username: Faisal Supir, plat_no: D FGH, latitude: -6.9484183, longitude: 107.63315, date_added: 2024-11-10}]

      for (var i = 0; i < dailyReport.length; i++) {
        var item = dailyReport[i];
        Map<String, String> listImgs = {
          item['tipe_attachment']: item['attachment']
        };

        if (!context.mounted) return;

        uploadReport(
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
      }
    }

    final scannedSnData = await DatabaseHelper.instance.getLastScannedSn();
    for (var item in scannedSnData) {
      await DatabaseHelper.instance.removeScannedSn(item['sn']);
      await Future.delayed(const Duration(seconds: 1));
    }
    await Future.delayed(const Duration(seconds: 3));
    OverlayLoadingProgress.stop();
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
}
