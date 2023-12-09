import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/scan_pengiriman/scan_pengiriman_screen.dart';
import 'package:sima_pengiriman/screens/turun_barang_online/controllers/turun_barang_online_controller.dart';
import 'package:http/http.dart' as http;
import '../../turun_barang_online/turun_barang_online.dart';

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

        for (var element in recordTugasDone) {
          print(element);
        }
      });
    });
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
                                // print(selectedTugas);
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
                            context, TurunBarangOnlineScreen.routeName);
                      },
                    );
                  },
                )
        ],
      ),
    );
  }
}
