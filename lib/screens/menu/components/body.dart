import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/courier_delivery_task_detail/delivery_task_detail.dart';
import 'package:sima_pengiriman/screens/delivery_order_menu/delivery_order_menu.dart';
import 'package:sima_pengiriman/screens/scan_pengiriman/scan_pengiriman_screen.dart';
import 'package:sima_pengiriman/screens/turun_barang_online/controllers/turun_barang_online_controller.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import '../../../enums.dart';
import '../../../helper/debouncer.dart';
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
      // print('common no ORder list W ${e}');
      for (var i in e) {
        kumpulanNoSJStr +=
            "'${i['nomor_order'].toString().replaceAll(' ', '')}',";
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
    final url = Uri.parse('${kURL_ORIGIN}pengiriman/sync-pengiriman-by-user');

    List dataList = await DatabaseHelper.instance.getDataTapForToday();

    Map<String, dynamic> requestBody = {"data": dataList};

    try {
      final username = await SharedToken.univGetterString('username');

      kumpulanNoSnStr += "''";
      final dataSend = {
        "supir": username,
        "kumpulan_sj_str": "''",
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
          } else {
            final Map<String, dynamic> tugasItem = {
              'nomor_order_surat_jalan': item['nomor_order'],
              'status_id': item['status_id'],
              'status_nama': item['status_nama'],
              'keterangan': item['keterangan']
            };

            await DatabaseHelper.instance.insertRecordTugasHistory(tugasItem);

            final Map<String, dynamic> itemInsert = {
              'nomor_order': item['nomor_order'],
              'identifier': item['identifier'],
              'sn': item['sn'],
              'long': item['long'],
              'lat': item['lat'],
              'location_id': item['location_id'],
              'customer_id': item['customer_id'],
              'creator': item['creator'],
              'date_added': item['date_added'],
              'date_modified': item['date_modified'],
              'status': item['status'],
              'customer_nama': item['customer_nama'],
              'customer_notelp': item['customer_notelp'],
              'supir': item['supir'],
              'items': '[]',
              'qty_sum': item['qty_sum']
            };

            await DatabaseHelper.instance.insertRecordTugas(itemInsert);
          }
        }
        statusSyncData = "DONE";
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      await taskNoLongerAssigned();
      List<dynamic> tugasValue =
          await DatabaseHelper.instance.getRecordTugasDT2();

      if (mounted) {
        if (tugasValue.isNotEmpty) {
          setState(() {
            recordTugas.clear();

            var newTugas = tugasValue
                .map((item) {
                  return {
                    ...item,
                    'selected': false,
                  };
                })
                .toSet()
                .toList();

            outerLoop:
            for (var element in newTugas) {
              var match = false;
              for (var el in recordTugas) {
                if (el['nomor_order'] == element['nomor_order']) {
                  match = true;
                  // Skip the current iteration of the outer loop
                  continue outerLoop;
                } else {
                  match = false;
                }
              }
              if (!match) {
                recordTugas.add(element);
              }
            }
          });
        }

        if (true) {
          if (mounted) {
            setState(() {
              recordTugas.add({
                'nomor_order': 'GO-086',
                'status_id': 0,
                'status_nama': 'Incomplete',
                'qty_sum': '3 Kg',
                'tipe_pengiriman': 'instant'
              });
            });
          }
        }

        List<dynamic> historyValue =
            await DatabaseHelper.instance.getHistorySuratJalan();

        if (mounted) {
          setState(() {
            recordTugasDone = historyValue;
          });

          sjDalamPengiriman(historyValue);
        }
      }
    } catch (error) {
      print('Err: $error');
    }
  }

  Future<void> taskNoLongerAssigned() async {
    try {
      final username = await SharedToken.univGetterString('username');

      final apiUrl = Uri.parse('${kURL_ORIGIN}pengiriman/sync-supir-beda');

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

  Future sjDalamPengiriman(List data) async {
    String strSJ = "";
    for (var element in data) {
      var noOd = element['nomor_order'].toString().replaceAll(' ', '');
      strSJ += "'$noOd',";
    }
    strSJ += "''";
    final url =
        Uri.parse('${kURL_ORIGIN}pengiriman/update-pengiriman-from-mobile');
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
    final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.list),
            InkWell(
              onTap: () {
                DatabaseHelper.instance.getRecordTugas().then((value) {
                  if (mounted) {}
                });
              },
              child: const Text(
                'Supir',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const Icon(Icons.person)
          ],
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
          ? const Center(
              child: CircularProgressIndicator(
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
                        child: recordTugas.isNotEmpty
                            ? ListView.builder(
                                itemCount: recordTugas.length,
                                itemBuilder: (BuildContext context, int index) {
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
                                      recordTugas[index]['status_id']
                                                      .toString() ==
                                                  '21' ||
                                              recordTugas[index]['status_id']
                                                      .toString() ==
                                                  '23'
                                          ? '${recordTugas[index]['status_nama']}'
                                          : 'Incompleted ',
                                      style: recordTugas[index]['status_id']
                                                      .toString() ==
                                                  '21' ||
                                              recordTugas[index]['status_id']
                                                      .toString() ==
                                                  '23'
                                          ? const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            )
                                          : const TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                    ),
                                    title:
                                        Text(recordTugas[index]["nomor_order"]),
                                    onTap: () async {
                                      var selectedTugas = recordTugas[index];

                                      if (selectedTugas['tipe_pengiriman'] !=
                                          null) {
                                        Navigator.pushNamed(context,
                                            DeliveryTaskDetail.routeName);
                                        return;
                                      }
                                      await ctl.getItemsByNoSJ([selectedTugas]);
                                      if (recordTugas[index]['status_id']
                                                  .toString() ==
                                              '21' ||
                                          recordTugas[index]['status_id']
                                                  .toString() ==
                                              '23') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Lanjutkan Pengiriman SJ?'),
                                            duration:
                                                const Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: 'Oke',
                                              onPressed: () {
                                                if (recordTugas[index]
                                                        ['tipe_pengiriman'] ==
                                                    null) {
                                                  Navigator.pushNamed(
                                                      context,
                                                      TurunBarangOnlineScreen
                                                          .routeName);
                                                } else {
                                                  Navigator.pushNamed(
                                                      context,
                                                      TurunBarangOnlineScreen
                                                          .routeName);
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.pushNamed(context,
                                          TurunBarangOnlineScreen.routeName);
                                    },
                                  );
                                },
                              )
                            : const Center(
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
                                Navigator.pushNamed(
                                    context, ScanPengirimanScreen.routeName);
                              },
                              child: const Text('Scan Pengiriman'))),
                    ),
                  ],
                ),
                recordTugasDone.isEmpty
                    ? const Center(
                        child: Text(
                            'Anda belum memiliki tugas silahkan klik tombol Scan Pengiriman untuk tugas anda hari ini'),
                      )
                    : ListView.builder(
                        itemCount: recordTugasDone.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                                '${recordTugasDone[index]['nomor_order']} '),
                            onTap: () async {
                              var selectedTugas = recordTugasDone[index];
                              await ctl.getItemsByNoSJ([selectedTugas]);
                              Navigator.pushNamed(context,
                                  TurunBarangOnlineHistoryScreen.routeName);
                            },
                          );
                        },
                      )
              ],
            ),
    );
  }
}
