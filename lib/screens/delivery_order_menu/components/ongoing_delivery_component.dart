import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

import '../../../constants.dart';
import '../../history_order/history_order_screen.dart';
import '../../summary_order/summary_order_screen.dart';
import 'package:http/http.dart' as http;

class OngoingDeliveryComponent extends StatefulWidget {
  const OngoingDeliveryComponent({super.key});

  @override
  State<OngoingDeliveryComponent> createState() =>
      _OngoingDeliveryComponentState();
}

class _OngoingDeliveryComponentState extends State<OngoingDeliveryComponent> {
  List onGoingDelivery = [];
  Future<void> makePostRequest() async {
    final userId = await SharedToken.univGetterString('user_id');
    final url = Uri.parse(
        '${kURL_ORIGIN}pengiriman/kurir/get-orders?user_id=$userId&length=0&limit=10');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body)['data'];
        if (mounted) {
          setState(() {
            onGoingDelivery.addAll(result);
          });
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String errorMessage =
            responseData['message']; // Adjust as per your API response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    makePostRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ongoing Delivery',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            itemCount: onGoingDelivery.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(onGoingDelivery[index]['order_code'] ?? 'EMPTY'),
                subtitle: Text(
                    onGoingDelivery[index]['destination_address'] ?? 'EMPTY'),
                leading: const Icon(Icons.list), // Just for illustration
                onTap: () {
                  Navigator.pushNamed(context, SummaryOrderScreen.routeName);
                  print('Tapped on item $index');
                },
                trailing: Text(onGoingDelivery[index]['status'] ?? 'EMPTY'),
              );
            },
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, HistoryOrderScreen.routeName);
          },
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              'See My Deliveries (1)',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            decoration: BoxDecoration(
              color: Colors.green,

              borderRadius:
                  BorderRadius.circular(20), // Adjust the value as needed
            ),
          ),
        )
      ],
    );
  }
}
