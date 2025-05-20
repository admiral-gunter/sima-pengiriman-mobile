import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../turun_barang_online/controllers/turun_barang_online_controller.dart';
import '../../turun_barang_online/turun_barang_online.dart';

class TapOrderPage extends StatelessWidget {
  const TapOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            String userInput = '';
            return AlertDialog(
              title: const Text('MASUKKAN NOMOR SJ',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              content: TextField(
                onChanged: (String value) => userInput = value.toUpperCase(),
                decoration: const InputDecoration(hintText: 'Type here...'),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final TurunBarangOnlineController ctl =
                        Get.put(TurunBarangOnlineController());
                    final snackBar = SnackBar(
                      content: Text('Mohon Tunggu...'),
                      backgroundColor: Colors.black,
                      duration: Duration(seconds: 2),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    ctl.listSJ.value = [];
                    ctl.listSelected.value = [];
                    ctl.listInv.value = [];
                    ctl.tapper.value = "";
                    ctl.listBarangPrioritas.value = [];
                    // ctl.nomorSJ.value = "";
                    // ctl.coordinate.value = {
                    //   'lat': '',
                    //   'long': ''
                    // };
                    // ctl.suratJalanCredential.value = {
                    //   'nama_toko': '',
                    //   'no_surat_jalan': ''
                    // };
                    // ctl.listLoc.value = [
                    //   {'': ''}
                    // ];
                    ctl.barangTap.value = 0;
                    ctl.barangHarusTap.value = 0;
                    await ctl.getItemsByNoSJStr(userInput).then((value) =>
                        Navigator.pushNamed(
                            context, TurunBarangOnlineScreen.routeName));
                    Navigator.pop(context); // Close dialog
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
      child: const Text('LANGSUNG TAP ORDER',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
