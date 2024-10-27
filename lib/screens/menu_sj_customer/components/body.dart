import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

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
      var result = jsonResponse['result'];

      // print(result.msg);
      // for (var suratJalan in result.result) {
      //   print('suratJalan ID: ${suratJalan.id}, Name: ${suratJalan.fullname}');
      // }

      setState(() {
        suratJalanList.addAll(result);
      });
    } else {
      // print(response.reasonPhrase);
      showErrorSnackbar(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    SharedToken.univGetterString('customer_id')
        .then((value) => {print(value), getsuratJalanBySupir(value)});

    super.initState();
  }

  void showErrorSnackbar(String? message) {
    final snackBar = SnackBar(
      content: Text(message ?? 'An error occurred'),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    await ctl.getItemsByNoSJStr(
                        suratJalanList[index]['nomer_surat_jalan']);
                    Navigator.pushNamed(
                        context, TurunBarangOnlineScreen.routeName);
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

                  // Navigate to OrderServiceScreen
                  Navigator.pushReplacementNamed(
                      context, OrderServiceScreen.routeName);
                } else {
                  print('Error: ${response.statusCode}');
                }
              } catch (e) {
                // Catch and handle any exceptions that occur
                print('An error occurred: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('An error occurred. Please try again.')),
                );
              }

              return;
              var request = http.Request(
                  'POST', Uri.parse('${kURL_ORIGIN}supir-get-toko-by-id'));

              http.StreamedResponse response = await request.send();

              if (response.statusCode == 200) {
                var resp = await response.stream.bytesToString();

                var jsonResponse = jsonDecode(resp);

                if (!jsonResponse['success']) {
                  SnackBar(
                    content: Text('${jsonResponse['msg']}'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        // Code to execute when "Undo" is pressed
                        print('Undo action pressed!');
                      },
                    ),
                  );

                  return;
                }

                var item = jsonResponse['result'];

                final OrderServiceController ctl =
                    Get.put(OrderServiceController());

                ctl.saleWholesaleCustomerIdSelected.value =
                    int.parse(item['swc_id']);

                ctl.saleWholesaleCustomerNamenAddress['address'] =
                    item['swc_address'];

                ctl.saleWholesaleCustomerNamenAddress['customer_name'] =
                    '${item['swc_shop_name']} (${item['swc_fullname']})';

                if (!mounted) return;

                Navigator.pushReplacementNamed(
                    context, OrderServiceScreen.routeName);

                return;

                if (!mounted) return;

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text('TOKO'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var item in jsonResponse['result'])
                                ElevatedButton(
                                    onPressed: () {
                                      final OrderServiceController ctl =
                                          Get.put(OrderServiceController());

                                      ctl.saleWholesaleCustomerIdSelected
                                          .value = int.parse(item['swc_id']);

                                      ctl.saleWholesaleCustomerNamenAddress[
                                          'address'] = item['swc_address'];

                                      ctl.saleWholesaleCustomerNamenAddress[
                                              'customer_name'] =
                                          '${item['swc_shop_name']} (${item['swc_fullname']})';

                                      Navigator.pushReplacementNamed(context,
                                          OrderServiceScreen.routeName);
                                    },
                                    child: Text(
                                        '${item['swc_shop_name']} (${item['swc_fullname']})'))
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              } else {
                print(response.reasonPhrase);
                SnackBar(
                  content: Text('${response.reasonPhrase}'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // Code to execute when "Undo" is pressed
                      print('Undo action pressed!');
                    },
                  ),
                );
              }
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
