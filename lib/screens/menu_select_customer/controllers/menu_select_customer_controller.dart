import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
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
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ));
    final scannedSnData = await DatabaseHelper.instance.getLastScannedSn();
    for (var item in scannedSnData) {
      await DatabaseHelper.instance.removeScannedSn(item['sn']);
      await Future.delayed(const Duration(seconds: 1));
    }
    await Future.delayed(const Duration(seconds: 3));
    OverlayLoadingProgress.stop();
  }
}
