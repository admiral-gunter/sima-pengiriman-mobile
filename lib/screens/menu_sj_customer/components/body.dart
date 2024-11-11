import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

import '../../menu_select_customer/controllers/menu_select_customer_controller.dart';
import '../../order_service/controll.ers/order_service_controller.dart';
import '../../order_service/order_service_screen.dart';
import '../../turun_barang_online/controllers/turun_barang_online_controller.dart';
import '../../turun_barang_online/turun_barang_online.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<dynamic> suratJalanList = [];

  Future<void> getsuratJalanBySupir(dynamic customerId) async {
    final supirId = await SharedToken.univGetterString('user_id');
    var request = http.Request(
      'POST',
      Uri.parse(
          '${kURL_ORIGIN}get-surat-jalan-by-customer-id?customer_id=$customerId&supir_id=$supirId'),
    );
    request.body = '''''';

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);
      List result = jsonResponse['result'];

      final customerId = await SharedToken.univGetterString('customer_id');

      for (var value in result) {
        try {
          if (value['nomer_surat_jalan'] == null) {
            continue;
          }
          String res = await DatabaseHelper.instance
              .insertNomorSj(int.parse(customerId), value['nomer_surat_jalan']);
          if (res != 'SUKSES') {
            showErrorSnackbar(res);
          }
        } catch (e) {
          showErrorSnackbar(
              'Error inserting nomor_sj for customerId: $customerId, error: $e');
        }
      }

      setState(() {
        suratJalanList.addAll(result);
      });
    } else {
      print(response.reasonPhrase);
      showErrorSnackbar(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    SharedToken.univGetterString('customer_id').then((value) {
      MenuSelectCustomerController ctl =
          Get.put(MenuSelectCustomerController());

      if (ctl.internetConnected.value) {
        getsuratJalanBySupir(value);
      } else {
        print('niggas offline');
        getSjOffline();
      }
    });

    super.initState();
  }

  void showErrorSnackbar(String? message) {
    final snackBar = SnackBar(
      content: Text(message ?? 'An error occurred'),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getSjOffline() async {
    try {
      var customerId = await SharedToken.univGetterString('customer_id');
      customerId = int.parse(customerId);

      print('id toko : $customerId');

      final result =
          await DatabaseHelper.instance.getNomorSjByIdToko(customerId);
      print('sj offline result : ');
      print(result);
      setState(() {
        suratJalanList.addAll(result);
      });
    } catch (e) {
      showErrorSnackbar('Error fetching nomor_sj: $e');
      // print('Error fetching nomor_sj: $e');
      // Optionally, you can handle errors further, like showing an error message in the UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: suratJalanList.length,
            itemBuilder: (context, index) {
              if (suratJalanList[index]['nomer_surat_jalan'] != null) {
                return ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(suratJalanList[index]['nomer_surat_jalan']),
                  // ignore: unnecessary_string_interpolations
                  // subtitle: Text('${suratJalanList[index].fullname}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
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
                    await ctl
                        .getItemsByNoSJStr(
                            suratJalanList[index]['nomer_surat_jalan'])
                        .then((value) => Navigator.pushNamed(
                            context, TurunBarangOnlineScreen.routeName));
                    // SharedToken.univSetterString('suratJalan_id', suratJalanList[index].id)
                    //     .then((value) => {
                    //           Navigator.pushReplacementNamed(
                    //               context, MenuSJsuratJalanScreen.routeName)
                    //         });
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text('Tapped on ')),
                    // );
                  },
                );
              }
              return null;
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              try {
                final tokoId =
                    await SharedToken.univGetterString('customer_id');
                var request = http.Request(
                    'POST',
                    Uri.parse(
                        '${kURL_ORIGIN}supir-get-toko-by-id?toko_id=$tokoId'));

                http.StreamedResponse response = await request.send();

                if (response.statusCode == 200) {
                  var resp = await response.stream.bytesToString();

                  var jsonResponse = jsonDecode(resp);

                  if (!jsonResponse['success']) {
                    // Handle failure by showing a SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${jsonResponse['msg']}'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            // Code to execute when "Undo" is pressed
                            print('Undo action pressed!');
                          },
                        ),
                      ),
                    );
                    return;
                  }

                  var item = jsonResponse['result'];
                  if (jsonResponse['result'] == []) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('An error occurred. Please try again.')),
                    );
                    return;
                  }
                  final OrderServiceController ctl =
                      Get.put(OrderServiceController());

                  // Safely parse swc_id as an int
                  ctl.saleWholesaleCustomerIdSelected.value =
                      int.tryParse(item['swc_id']) ??
                          0; // Default to 0 if parsing fails

                  ctl.saleWholesaleCustomerNamenAddress['address'] =
                      item['swc_address'];

                  ctl.saleWholesaleCustomerNamenAddress['customer_name'] =
                      '${item['swc_shop_name']} (${item['swc_fullname']})';

                  if (!mounted) return;

                  Navigator.pushReplacementNamed(
                      context, OrderServiceScreen.routeName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'An error occurred. ERROR : ${response.statusCode}')),
                  );
                }
              } catch (e) {
                // Catch and handle any exceptions that occur
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('An error occurred. ERROR : $e')),
                );
              }

              return;
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child:
                Text('Service Titipan', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
