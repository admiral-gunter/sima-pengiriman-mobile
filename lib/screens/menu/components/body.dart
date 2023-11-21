import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/grosir_tap_out/grosir_tap_out.dart';
import 'package:sima_pengiriman/screens/purchase_order/purchase_order_screen.dart';
import 'package:sima_pengiriman/screens/retail_tap_out/retail_tap_out_screen.dart';
import 'package:sima_pengiriman/screens/scan_pengiriman/scan_pengiriman_screen.dart';
import 'package:sima_pengiriman/screens/service_offline/controller/service_offline_controller.dart';
import 'package:sima_pengiriman/screens/service_offline/service_offline_screen.dart';
import 'package:sima_pengiriman/screens/turun_barang_offline/turun_barang_offline_screen.dart';
import 'package:sima_pengiriman/screens/turun_barang_online/controllers/turun_barang_online_controller.dart';

import '../../../constants.dart';
import '../../pindah_gudang_offline/pindah_gudang_offline_screen.dart';
import '../../purchase_order_offline/purchase_order_offline_screen.dart';
import '../../turun_barang_online/turun_barang_online.dart';
import '../../universal_scannner/controller/universal_scanner_data.dart';

class ParentItem {
  final String title;
  final List<ChildItem> childList;
  final String route;

  ParentItem(this.title, this.childList, [this.route = '']);
}

class ChildItem {
  final String title;
  final String route;

  ChildItem(this.title, [this.route = '']);
}

List<ParentItem> parentList = [
  ParentItem(
    "Dashboard",
    [],
  ),
  // ParentItem(
  //   "Pembelian",
  //   [
  //     ChildItem("Terima Barang (PO)", ListPoScreen.routeName),
  //   ],
  // ),
  // ParentItem(
  //   "Fitur Offline",
  //   [
  //     ChildItem("Terima Barang (PO)", PurchaseOrderOfflineScreen.routeName),
  //     ChildItem("Out Grosir", GrosirTapOut.routeName),
  //     ChildItem("Out Retail", RetailTapOutScreen.routeName),
  //     ChildItem("Pindah Gudang (Terima)", '/pindah-gudang-offline-terima'),
  //     ChildItem("Pindah Gudang (Keluar)", '/pindah-gudang-offline-keluar'),
  //     ChildItem("Service", ServiceOfflineScreen.routeName),
  //   ],
  // )
];

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List recordTugas = [];
  List recordTugasDone = [];

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.getRecordTugas().then((value) {
      setState(() {
        // for (var element in recordTugas) {
        //   element['selected'] = true;
        // }
        for (var i = 0; i < recordTugas.length; i++) {
          recordTugas[i]['selected'] = false;
        }
        // recordTugas.addAll(value);
        recordTugas = value.map((item) {
          return {
            ...item,
            'selected': false,
          };
        }).toList();
      });
    });

    DatabaseHelper.instance.getHistorySuratJalan().then((value) {
      setState(() {
        recordTugasDone = value;

        for (var element in recordTugasDone) {
          print(element);
        }
      });
    });
    _tabController = TabController(length: 2, vsync: this); // Number of tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.list),
              InkWell(
                onTap: () {
                  DatabaseHelper.instance.getRecordTugas().then((value) {
                    setState(() {
                      // for (var element in recordTugas) {
                      //   element['selected'] = true;
                      // }
                      for (var i = 0; i < recordTugas.length; i++) {
                        recordTugas[i]['selected'] = false;
                      }
                      // recordTugas.addAll(value);
                      recordTugas = value.map((item) {
                        return {
                          ...item,
                          'selected': false,
                        };
                      }).toList();
                    });
                  });
                },
                child: Text(
                  'Supir',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Icon(Icons.person)
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'Tugas Anda',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Tab(
              child: Text(
                'History',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Expanded(
                  child: recordTugas.length != 0
                      ? ListView.builder(
                          itemCount:
                              recordTugas.length, // Number of items in the list
                          itemBuilder: (BuildContext context, int index) {
                            bool isRecordDone = recordTugasDone.any(
                                (doneItem) =>
                                    doneItem["nomor_order"] ==
                                    recordTugas[index]["nomor_order"]);

                            // If it exists, skip the iteration
                            if (isRecordDone) {
                              return SizedBox
                                  .shrink(); // This widget has zero size and is invisible
                            }
                            return ListTile(
                              leading: Checkbox(
                                value: recordTugas[index]['selected'],
                                onChanged: (value) {
                                  setState(() {
                                    recordTugas[index]['selected'] =
                                        !recordTugas[index]['selected'];
                                  });
                                },
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Toko : ${recordTugas[index]['customer_nama'].split("-")[1]}'),
                                  if (recordTugas[index]['items'] != null)
                                    Text(''),
                                ],
                              ),
                              trailing: Text(
                                'Incompleted',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                              title: Text(recordTugas[index]["nomor_order"]),
                              onTap: () async {
                                var selectedTugas = recordTugas
                                    .where((tugas) => tugas['selected'] == true)
                                    .toList();

                                if (selectedTugas.length > 0) {
                                  // ctl.getListItems(selectedTugas);
                                  await ctl.getItemsByNoSJ(selectedTugas);
                                  Navigator.pushNamed(context,
                                      TurunBarangOnlineScreen.routeName);
                                  // You can add custom actions when a list item is tapped
                                  print('Tapped on item $index');
                                } else {
                                  final snackBar = SnackBar(
                                    content: Text('Pilih Minimal 1 Tugas'),
                                    action: SnackBarAction(
                                      label: 'Dismiss',
                                      onPressed: () {
                                        // Some action to perform
                                      },
                                    ),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                            );
                          },
                        )
                      : Center(
                          child: Text(
                              'Anda belum memiliki tugas silahkan klik tombol Scan Pengiriman untuk tugas anda hari ini'),
                        )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, ScanPengirimanScreen.routeName);
                        },
                        child: Text('Scan Pengiriman'))),
              ),
            ],
          ),
          // Content for Tab 2
          recordTugasDone.length == 0
              ? Center(
                  child: Text(
                      'Anda belum memiliki tugas silahkan klik tombol Scan Pengiriman untuk tugas anda hari ini'),
                )
              : ListView.builder(
                  itemCount: recordTugasDone.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('${recordTugasDone[index]['nomor_order']}'),
                      subtitle: Text(
                          'Toko : ${recordTugasDone[index]['nama_toko'].split("-")[1]}'),
                      onTap: () {
                        // Do something when the tile is tapped
                        print('Tapped on item $index');
                      },
                    );
                  },
                )
        ],
      ),
    );
  }
}
