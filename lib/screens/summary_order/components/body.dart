import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared_preferences/shared_token.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  var selectedOrderCode = '';
  var selectedOrderItem = {};
  @override
  void initState() {
    super.initState();
    SharedToken.univGetterString('selected_order_code').then((value) => {
          SharedToken.univGetterString('selected_order_item').then((value) => {
                setState(() {
                  selectedOrderItem = jsonDecode(value);
                })
              }),
          setState(() {
            selectedOrderCode = value;
          })
        });
  }

  String convertDateFormat(String inputText) {
    // Parse the input text into a DateTime object
    DateTime dateTime = DateTime.parse(inputText.trim());

    // Format the DateTime object to get the desired format
    String formattedDate = DateFormat('d MMMM').format(dateTime);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double halfScreenWidth = screenWidth / 2;
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sima Delivery',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Text(
                  convertDateFormat(selectedOrderItem['created_at']) ?? 'EMPTY',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedOrderItem['status'],
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Order No ${selectedOrderCode}'),
              ],
            ),
            SizedBox(
              height: 5,
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: halfScreenWidth,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Driver '),
                          Text(':'),
                          Text('Ridwan Kamil',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Plat No '),
                          Text(':'),
                          Text('D 98543 FG'),
                        ],
                      )
                    ],
                  ),
                ),
                Text('Delivery Detail'),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 0.5, // Adjust this value for the thickness
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pickup Address'),
                          Text(
                            selectedOrderItem['pickup_address']
                                    .toString()
                                    .substring(0, 30) ??
                                'EMPTY',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          Container(
                            decoration:
                                BoxDecoration(color: Colors.purple[100]),
                            child: Row(children: [
                              Icon(Icons.attachment, color: Colors.purple),
                              Text(
                                'attachment',
                                style: TextStyle(color: Colors.purple),
                              )
                            ]),
                          ),
                          Text('picked up from muh rafli')
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 0.5, // Adjust this value for the thickness
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Delivery Address'),
                          Text(
                            selectedOrderItem['destination_address']
                                    .toString()
                                    .substring(0, 30) ??
                                'EMPTY',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          Container(
                            decoration: BoxDecoration(color: Colors.green[100]),
                            child: Row(children: [
                              Icon(Icons.attachment, color: Colors.green),
                              Text(
                                'attachment',
                                style: TextStyle(color: Colors.green),
                              )
                            ]),
                          ),
                          Text('received by muh rafli')
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 0.5, // Adjust this value for the thickness
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Total Weight',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black),
                      ),
                      Text('8Kg')
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 0.5, // Adjust this value for the thickness
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('Total Tariffs',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery'),
                          Text('20.000'),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total'),
                          Text('20.000'),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
