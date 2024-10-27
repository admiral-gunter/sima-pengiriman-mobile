import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import '../../menu_sj_customer/menu_sj_customer_screen.dart';
import '../../scan_pengiriman/scan_pengiriman_screen.dart';
import '../models/customer_model.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<Customer> customerList = [];

  Future<void> getCustomerBySupir(int supirId) async {
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

      // print(result.msg);
      // for (var customer in result.result) {
      //   print('Customer ID: ${customer.id}, Name: ${customer.fullname}');
      // }

      setState(() {
        customerList.addAll(result.result);
      });
    } else {
      // print(response.reasonPhrase);
      showErrorSnackbar(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    SharedToken.univGetterString('user_id').then(((value) {
      int val = int.parse(value);
      getCustomerBySupir(val);
    }));
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
                // ignore: unnecessary_string_interpolations
                subtitle: Text('${customerList[index].fullname}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  SharedToken.univSetterString(
                          'customer_id', customerList[index].id)
                      .then((value) => {
                            Navigator.pushNamed(
                                context, MenuSJCustomerScreen.routeName)
                          });
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('Tapped on ')),
                  // );
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
