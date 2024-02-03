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

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List recordTugas = [];
  List recordTugasDone = [];
  String kumpulanNoOrderStr = '';
  String kumpulanNoSJStr = "";

  @override
  void initState() {
    super.initState();
    // THESE FUNCTION ARE HEAVY AND UNSTABLE
    // REFACTOR WITH SCROLLING ALGORITHM SOON
    // GET DATA SJ LIMIT 20
    // GET ITEM SN ONLY WHEN CLICKED AT SJ
    // THEN INSERT
    syncDataTap().then((value) => getsyncDataTapInsert().then((value) => null));

    _tabController = TabController(length: 2, vsync: this); // Number of tabs
  }

  Future syncDataTap() async {
    try {
      final e = await DatabaseHelper.instance.getRecordTugasDT();
      print('common no ORder list W ${e}');
      for (var i in e) {
        kumpulanNoSJStr +=
            "'" + i['nomor_order'].toString().replaceAll(' ', '') + "',";
      }
      kumpulanNoSJStr += "''";
    } catch (error) {
      print('Error: $error');
    }
  }

  //LOADING; DONE; ERROR
  String statusSyncData = "LOADING";
  String kumpulanNoSnStr = "";
  Future getsyncDataTapInsert() async {
    final url = Uri.parse(kURL_ORIGIN + 'pengiriman/sync-pengiriman-by-user');

    List dataList = await DatabaseHelper.instance.getDataTapForToday();

    Map<String, dynamic> requestBody = {"data": dataList};

    try {
      final username = await SharedToken.univGetterString('username');

      final turunBarang = await DatabaseHelper.instance.getBarangTurunDT();
      for (var i in turunBarang) {
        kumpulanNoSnStr += "'" + i['sn'] + "',";
      }
      kumpulanNoSnStr += "''";
      final dataSend = {
        "supir": username,
        "kumpulan_sj_str": kumpulanNoSJStr,
        "kumpulan_no_sn_str": kumpulanNoSnStr,
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
          if (item['status'] == 'COMPLETED' || item['status'] == 'CANCELLED') {
            final e = await DatabaseHelper.instance
                .insertHistorySuratJalan((newITem));
          } else {
            item.remove('id');
            item.remove('status');

            final e = await DatabaseHelper.instance.insertRecordTugas(item);
          }
        }
        statusSyncData = "DONE";
        print('Request successful');
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      await taskNoLongerAssigned();
      DatabaseHelper.instance.getRecordTugasDT2().then((value) {
        if (mounted) {
          setState(() {
            for (var i = 0; i < recordTugas.length; i++) {
              print('${recordTugas[i]} LE RECORD');
              recordTugas[i]['selected'] = false;
            }
            recordTugas = value.map((item) {
              return {
                ...item,
                'selected': false,
              };
            }).toList();
          });
          DatabaseHelper.instance.getHistorySuratJalan().then((value) {
            if (mounted) {
              setState(() {
                recordTugasDone = value;
              });

              SJDalamPengiriman(value);
            }
          });
        }
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> taskNoLongerAssigned() async {
    try {
      final username = await SharedToken.univGetterString('username');

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
                    if (mounted) {
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
                    }
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
      body: statusSyncData == "LOADING"
          ? Center(
              child: CircularProgressIndicator(
                // Customize the appearance of the CircularProgressIndicator
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : TabBarView(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                    title:
                                        Text(recordTugas[index]["nomor_order"]),
                                    onTap: () async {
                                      var selectedTugas = recordTugas[index];
                                      await ctl.getItemsByNoSJ([selectedTugas]);
                                      Navigator.pushNamed(context,
                                          TurunBarangOnlineScreen.routeName);
                                    },
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                    'Anda belum memiliki tugas silahkan klik tombol Scan Pengiriman untuk tugas anda hari ini'),
                              )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2.0),
                      child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                if (recordTugas.length > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Masih Ada Surat Jalan Belum Selesai'),
                                    ),
                                  );
                                  return;
                                }
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
                            title: Text(
                                '${recordTugasDone[index]['nomor_order']} '),
                            trailing: Text(
                              recordTugasDone[index]['status'] == 'batal_kirim'
                                  ? '${recordTugasDone[index]['status']}'
                                  : '', // Empty text if the condition is false
                              style: TextStyle(color: Colors.red
                                  // Your text style here
                                  ),
                            ),
                            onTap: () async {
                              var selectedTugas = recordTugasDone[index];
                              await ctl.getItemsByNoSJ([selectedTugas]);
                              Navigator.pushNamed(context,
                                  TurunBarangOnlineHistoryScreen.routeName);
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
