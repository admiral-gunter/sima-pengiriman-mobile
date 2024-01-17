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
    syncDataTap().then((value) => getsyncDataTapInsert().then((value) => null));
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

  String kumpulanNoOrderStr = '';
  String kumpulanNoSJStr = "";

  Future getsyncDataTapInsert() async {
    final url = Uri.parse(kURL_ORIGIN + 'pengiriman/sync-pengiriman-by-user');

    List dataList = await DatabaseHelper.instance.getDataTapForToday();

    Map<String, dynamic> requestBody = {"data": dataList};

    try {
      final e = await DatabaseHelper.instance.getRecordTugasDT();
      final username = await SharedToken.univGetterString('username');

      for (var i in e) {
        kumpulanNoSJStr +=
            "'" + i['nomor_order'].toString().replaceAll(' ', '') + "',";
      }
      kumpulanNoSJStr += "''";

      final turunBarang = await DatabaseHelper.instance.getBarangTurunDT();
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
      await taskNoLongerAssigned();
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
        });

        SJDalamPengiriman(value);
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> taskNoLongerAssigned() async {
    try {
      final username = await SharedToken.univGetterString('username');

      // var apiUrl = Uri.parse('https://example.com/api/endpoint');
      final apiUrl = Uri.parse(kURL_ORIGIN + 'pengiriman/sync-supir-beda');

      var data = {'sj': kumpulanNoSJStr, 'supir': username};

      var response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: data,
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        List content = res['content'];
        if (content.isNotEmpty) {
          List strlist = [];

          for (var i = 0; i < content.length; i++) {
            strlist.add(content[i]["no_surat_jalan"]);
            await DatabaseHelper.instance
                .deleteRecordTugasByNomorOrder(content[i]["no_surat_jalan"]);
          }

          // await DatabaseHelper.instance.deleteRecordTugasByNomorOrder(strlist);
          print('el based ${strlist}');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future SJDalamPengiriman(List data) async {
    String strSJ = "";
    for (var element in data) {
      var noOd = element['nomor_order'].toString().replaceAll(' ', '');
      strSJ += "'" + noOd + "',";
    }
    strSJ += "'" + "" + "'";
    final url =
        Uri.parse(kURL_ORIGIN + 'pengiriman/update-pengiriman-from-mobile');
    Map<String, dynamic> requestBody = {"sj": strSJ, "status": "2"};

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
      print('Error making POST request SJ Peng: $error');
    }
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
