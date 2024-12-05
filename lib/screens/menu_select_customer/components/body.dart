import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/screens/menu_select_customer/menu_select_customer.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import '../../../helper/database_helper.dart';
import '../../daily_report_driver/daily_report_driver_screen.dart';
import '../../delivery_order_menu/delivery_order_menu.dart';
import '../../menu_sj_customer/menu_sj_customer_screen.dart';
import '../../scan_pengiriman/scan_pengiriman_screen.dart';
import '../../sign_in/sign_in_screen.dart';
import '../controllers/menu_select_customer_controller.dart';
import '../models/customer_model.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<Customer> customerList = [];

  Future<void> getCustomerBySupir(int supirId) async {
    try {
      var request = http.Request(
        'POST',
        Uri.parse('${kURL_ORIGIN}get-customer-by-supir?supir_id=$supirId'),
      );
      request.body = '''''';

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // print(await response.stream.bytesToString());
        String responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        var result = GetCustomerBySupirResponse.fromJson(jsonResponse);

        for (var value in result.result) {
          String res = await DatabaseHelper.instance.insertAssignedCustomer(
              value.fullname,
              value.shopName,
              int.parse(value.saleWholesaleCustomerId),
              int.parse(value.supirId),
              value.namaSupir);

          if (res != 'SUKSES') {
            showErrorSnackbar(res);
            return;
          }
        }

        if (!mounted) return;

        setState(() {
          _isLoading = false;
          customerList.addAll(result.result);
        });
      } else {
        showErrorSnackbar(response.reasonPhrase);
      }
    } catch (e) {
      showErrorSnackbar('ERROR : $e, running app in offline mode');
    }
  }

  initReportTable() async {
    final re = await DatabaseHelper.instance.getOrderServices();

    print('nigger');
    print(re);
    final tbSetted = await SharedToken.univGetterString('tb_setted');
    if (tbSetted == null) {
      await DatabaseHelper.instance.createOrderServicesTable();
      await DatabaseHelper.instance.createDailyReportSupirTable();
      await DatabaseHelper.instance.updateTb();
      await DatabaseHelper.instance.createOrderServicesOfflineAttachment();
      await SharedToken.univSetterString('tb_setted', 'yes');
    }
  }

  @override
  void initState() {
    checkTokenAndNavigate().then((value) {
      _cekAbsensi().then((value) => {
            SharedToken.univGetterString('user_id').then(((value) async {
              int val = int.parse(value);

              await DatabaseHelper.instance.getLastDailyReportSupir();

              final MenuSelectCustomerController ctl =
                  Get.put(MenuSelectCustomerController());

              if (!mounted) return;

              if (ctl.internetConnected.value) {
                ctl.syncApp(context);
                await getCustomerBySupir(val);
              } else {
                showErrorSnackbar('Tidak ada koneksi internet!');
                getCustomersOffline();
              }

              // try {
              //   final result = await InternetAddress.lookup('example.com');

              //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
              //     await getCustomerBySupir(val);
              //     await DatabaseHelper.instance.getLastDailyReportSupir();

              //     final MenuSelectCustomerController ctl =
              //         Get.put(MenuSelectCustomerController());

              //     if (!mounted) return;

              //     if (ctl.internetConnected.value) {
              //       ctl.syncApp(context);
              //     } else {
              //       getCustomersOffline();
              //     }

              //     ctl.syncApp(context);
              //   }
              // } on SocketException catch (_) {
              //   getCustomersOffline();
              // }
            }))
          });
    });

    super.initState();
  }

  Future<void> getCustomersOffline() async {
    List<Customer> customers =
        (await DatabaseHelper.instance.getAssignedCustomers()).cast<Customer>();
    setState(() {
      _isLoading = false;
      customerList.addAll(customers);
    });
  }

  Future<void> checkTokenAndNavigate() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final uRole = await SharedToken.univGetterString('USER_ROLE');
      String? token = prefs.getString('token');
      await initReportTable();
      if (!mounted) return;
      print('migger sukses');
      String? currentRoute = ModalRoute.of(context)?.settings.name;

      if (token != null && uRole == 'USER_SENDER') {
        // print('retard');
        Navigator.pushReplacementNamed(context, DeliverOrderMenu.routeName);
        return;
      }

      if (token != null && currentRoute != MenuSelectCustomer.routeName) {
        Navigator.pushReplacementNamed(context, MenuSelectCustomer.routeName);
      } else if (token == null && currentRoute != SignInScreen.routeName) {
        await DatabaseHelper.instance.emptyAllTables();

        await SharedToken.tokenRemover();
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      }
    } catch (e) {
      print('Error $e');
    }
  }

  Future _cekAbsensi() async {
    final MenuSelectCustomerController ctl =
        Get.put(MenuSelectCustomerController());
    if (!ctl.internetConnected.value) {
      List<Map> res = await DatabaseHelper.instance.getDailyReportSupirToday();

      if (res.isEmpty) {
        await SharedToken.univSetterString('STS_ABSEN', 'BELUM_ABSEN');

        Navigator.pushReplacementNamed(
            context, DailyReportDriverScreen.routeName);
      }
      return;
    }

    // return;

    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST', Uri.parse('${kURL_ORIGIN}cek-supir-km-insert-absen'));

    final username = await SharedToken.univGetterString('username');
    request.bodyFields = {'created_by': username};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var resp = await response.stream.bytesToString();
      // Decode the response body as JSON
      var jsonResp = jsonDecode(resp);

      if (jsonResp['msg'] == 'SUPIR_BELUM_ABSEN') {
        await SharedToken.univSetterString('STS_ABSEN', 'BELUM_ABSEN');

        if (!mounted) return;
        Navigator.pushReplacementNamed(
            context, DailyReportDriverScreen.routeName);
      } else {
        await SharedToken.univSetterString('STS_ABSEN', '');
        if (!mounted) return;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      showErrorSnackbar(response.reasonPhrase);
    }
  }

  void showErrorSnackbar(String? message) {
    final snackBar = SnackBar(
      content: Text(message ?? 'An error occurred'),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (customerList.isEmpty) {
      return const Center(
        child: Text('Surat Jalan belum dibuat'),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: customerList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.home),
                title: Text(customerList[index].shopName),
                subtitle: Text(customerList[index].fullname),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  SharedToken.univSetterString(
                          'customer_id', customerList[index].id)
                      .then((value) => {
                            Navigator.pushNamed(
                                context, MenuSJCustomerScreen.routeName)
                          });
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
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
    );
  }
}
