import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/scan_pengiriman/scan_pengiriman_screen.dart';
import 'package:sima_pengiriman/screens/turun_barang_online/controllers/turun_barang_online_controller.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:sqflite/sqflite.dart';
import '../../turun_barang_online/turun_barang_online.dart';
import '../../turun_barang_online/turun_barang_online_history.dart';

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
    syncDataTap();
    getsyncDataTapInsert();
    // DatabaseHelper.instance.getRecordTugas().then((value) {
    //   setState(() {
    //     for (var i = 0; i < recordTugas.length; i++) {
    //       recordTugas[i]['selected'] = false;
    //     }
    //     recordTugas = value.map((item) {
    //       return {
    //         ...item,
    //         'selected': false,
    //       };
    //     }).toList();
    //   });
    // });

    // DatabaseHelper.instance.getHistorySuratJalan().then((value) {
    //   setState(() {
    //     recordTugasDone = value;

    //     for (var element in recordTugasDone) {
    //       print(element);
    //     }
    //   });
    // });
    _tabController = TabController(length: 2, vsync: this); // Number of tabs
  }

  Future syncDataTap() async {
    final url = Uri.parse(kURL_ORIGIN + 'pengiriman/sync-data-pengiriman');

    List dataList = await DatabaseHelper.instance.getDataTapForToday();

    Map<String, dynamic> requestBody = {"data": dataList};

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"data": jsonEncode(requestBody)},
      );

      final e = await DatabaseHelper.instance.getRecordTugasDT();
      String kumpulanNoOrderStr = "";

      for (var i in e) {
        kumpulanNoOrderStr += "'" + i['nomor_order'] + "',";
      }
      kumpulanNoOrderStr += "''";

      print('LE : ${e}');
      if (response.statusCode == 200) {
        print('Request successful');
        print('Response body: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future getsyncDataTapInsert() async {
    final url = Uri.parse(kURL_ORIGIN + 'pengiriman/sync-pengiriman-by-user');

    List dataList = await DatabaseHelper.instance.getDataTapForToday();

    Map<String, dynamic> requestBody = {"data": dataList};

    try {
      final e = await DatabaseHelper.instance.getRecordTugasDT();
      String kumpulanNoSJStr = "";
      final username = await SharedToken.univGetterString('username');

      for (var i in e) {
        kumpulanNoSJStr +=
            "'" + i['nomor_order'].toString().replaceAll(' ', '') + "',";
      }
      kumpulanNoSJStr += "''";

      final turunBarang = await DatabaseHelper.instance.getBarangTurunDT();
      String kumpulanNoOrderStr = '';
      for (var i in turunBarang) {
        kumpulanNoOrderStr += "'" + i['sn'] + "',";
      }
      kumpulanNoOrderStr += "''";

      final dataSend = {
        "supir": username,
        "kumpulan_sj_str": kumpulanNoSJStr,
        "kumpulan_no_sn_str": kumpulanNoOrderStr,
        "supir_actual": username,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: dataSend,
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        for (var item in result['content2']) {
          DatabaseHelper.instance.insertBarangTurun(item);
        }

        for (var item in result['tapped_sj']) {
          print('le work');
          final newITem = {
            'nomor_order': item['nomor_order'],
            'nama_toko': 'NONE',
            'creator': item['creator'],
            'date_added': item['date_added'],
            'date_modified': item['date_modified'],
            'customer_nama': item['customer_nama'],
            'customer_notelp': item['customer_notelp'],
            'supir': item['creator'],
            'tapper': item['creator'],
          };
          if (item['status'] == 'COMPLETED') {
//             print('le work ${item}');
//  {
//             "id": "20",
//             "nomor_order": " SJ-2023-12-24-120",
//             "identifier": "YourIdentifierValue",
//             "sn": "YourSNValue",
//             "long": "107.7308754",
//             "lat": "-6.9492631",
//             "location_id": "123",
//             "customer_id": "456",
//             "creator": "sima",
//             "date_added": "2023-12-27 21:10:09",
//             "date_modified": "2023-12-27 21:10:09",
//             "status": "COMPLETED",
//             "customer_nama": "JUJU 1-sima-- ",
//             "customer_notelp": "CustomerPhoneNumber",
//             "supir": "DriverName",
//             "items": "[]",
//             "qty_sum": "2"
//         },

//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//         nomor_order TEXT UNIQUE,
//         nama_toko TEXT,
//         creator TEXT,
//         date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
//         date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
//         status TEXT CHECK(status IN ('unvalidasi', 'validasi')) DEFAULT 'unvalidasi' NOT NULL,
//         customer_nama TEXT,
//         customer_notelp TEXT,
//         supir TEXT,
//         tapper TEXT

            final e = await DatabaseHelper.instance
                .insertHistorySuratJalan((newITem));
            print('le e ${e}');
          } else {
            item.remove('id');
            item.remove('status');

            final e = await DatabaseHelper.instance.insertRecordTugas(item);
            print('le e ${e}');
          }
        }
        print('Request successful');
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      DatabaseHelper.instance.getRecordTugas().then((value) {
        setState(() {
          for (var i = 0; i < recordTugas.length; i++) {
            recordTugas[i]['selected'] = false;
          }
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

          for (var element in recordTugasDone) {}
        });
      });
    } catch (error) {
      print('Error: $error');
    }
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
                      for (var i = 0; i < recordTugas.length; i++) {
                        recordTugas[i]['selected'] = false;
                      }
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
                          itemCount: recordTugas.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isRecordDone = recordTugasDone.any(
                                (doneItem) =>
                                    doneItem["nomor_order"] ==
                                    recordTugas[index]["nomor_order"]);

                            if (isRecordDone) {
                              return SizedBox.shrink();
                            }
                            return ListTile(
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Barang : ${recordTugas[index]['qty_sum']}')
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
                                var selectedTugas = recordTugas[index];
                                await ctl.getItemsByNoSJ([selectedTugas]);
                                Navigator.pushNamed(
                                    context, TurunBarangOnlineScreen.routeName);
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
                      onTap: () async {
                        var selectedTugas = recordTugasDone[index];
                        await ctl.getItemsByNoSJ([selectedTugas]);
                        Navigator.pushNamed(
                            context, TurunBarangOnlineHistoryScreen.routeName);
                        // Navigator.pushNamed(
                        //     context, TurunBarangOnlineScreen.routeName);
                      },
                    );
                  },
                )
        ],
      ),
    );
  }
}
