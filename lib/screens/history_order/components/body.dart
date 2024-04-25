import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../helper/debouncer.dart';
import '../../../shared_preferences/shared_token.dart';
import '../../summary_order/summary_order_screen.dart';
import 'package:http/http.dart' as http;

class Body extends StatefulWidget {
  Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));
  var myDeliveries = [];
  var length = 0;
  var search = '';
  Future<void> getMyOrders() async {
    final userId = await SharedToken.univGetterString('user_id');
    var url = Uri.parse(
        '${kURL_ORIGIN}pengiriman/kurir/get-orders?user_id=$userId&length=${length}&limit=10&search=${search}');

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
            myDeliveries.addAll(result);
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

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyOrders();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the bottom
      // Call your function here
      length += 10;
      getMyOrders();
      print('Reached the bottom');
      // Run your function here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onChanged: (value) {
            search = value;
            setState(() {
              myDeliveries.length = 0;
            });
            _debouncer.run(() {
              getMyOrders();
              print('Action after 0.5 seconds: $value');
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari Order...', // Placeholder text
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: myDeliveries.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(myDeliveries[index]['order_code'] ?? 'EMPTY'),
                subtitle:
                    Text(myDeliveries[index]['destination_address'] ?? 'EMPTY'),
                leading: const Icon(Icons.list), // Just for illustration
                onTap: () async {
                  await SharedToken.univSetterString(
                      'selected_order_code', myDeliveries[index]['order_code']);

                  await SharedToken.univSetterString(
                      'selected_order_item', jsonEncode(myDeliveries[index]));
                  Navigator.pushNamed(context, SummaryOrderScreen.routeName);
                  print('Tapped on item $index');
                },
                trailing: Text(myDeliveries[index]['status'] ?? 'EMPTY'),
              );
            },
          ),
        ),
      ],
    );
  }
}
