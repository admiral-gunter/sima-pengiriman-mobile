import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import '../models/customer_model.dart';

class BodySelectCustomer extends StatefulWidget {
  const BodySelectCustomer({super.key});

  @override
  State<BodySelectCustomer> createState() => _BodySelectCustomerState();
}

class _BodySelectCustomerState extends State<BodySelectCustomer> {
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
    return ListView.builder(
      itemCount: customerList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.home),
          title: Text(customerList[index].shopName),
          // ignore: unnecessary_string_interpolations
          subtitle: Text('${customerList[index].fullname}'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Handle tile tap here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on ')),
            );
          },
        );
      },
    );
  }
}
