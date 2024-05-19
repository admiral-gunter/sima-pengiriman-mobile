import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/components/coustom_bottom_nav_bar.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/screens/delivery_order_menu/components/ongoing_delivery_component.dart';
import 'package:sima_pengiriman/screens/delivery_package_by_weight/delivery_package_by_weight_screen.dart';
import 'package:sima_pengiriman/screens/history_turun_barang/history_turun_barang.dart';
import 'package:sima_pengiriman/screens/out_of_town_cargo/out_of_town_cargo_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

import '../../enums.dart';
import '../../helper/debouncer.dart';
import '../delivery_instant/controllers/delivery_form_controller.dart';
import '../delivery_instant/delivery_instant_screen.dart';
import '../history_order/history_order_screen.dart';
import '../summary_order/summary_order_screen.dart';
import 'package:http/http.dart' as http;

class DeliverOrderMenu extends StatefulWidget {
  DeliverOrderMenu({super.key});

  static String routeName = "/delivery-order-menu";

  @override
  State<DeliverOrderMenu> createState() => _DeliverOrderMenuState();
}

class _DeliverOrderMenuState extends State<DeliverOrderMenu> {
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  String cntOrder = '0';

  Future getCntOrder() async {
    // Define the endpoint URL
    final userId = await SharedToken.univGetterString('user_id');
    var url = Uri.parse(
        '${kURL_ORIGIN}pengiriman/kurir/get-supir-task-cnt?user_id=$userId');

    // Define the request body (if needed)

    // Make the POST request
    var response = await http.post(url);

    // Check the status code of the response
    if (response.statusCode == 200) {
      print('Request successful');
      print('Response: ${response.body}');
      setState(() {
        cntOrder = jsonDecode(response.body);
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCntOrder();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Hi '),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: TabBarView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Column(children: [
                        Text('You Have ${cntOrder} Deliveries On-Going'),
                        SizedBox(
                          height: 20,
                        )
                      ]),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                                onPressed: () async {
                                  await SharedToken.univSetterString(
                                      'backToMenu',
                                      DeliveryInstantScreen.routeName);
                                  final DeliveryFormController ctl =
                                      Get.put(DeliveryFormController());
                                  ctl.form = {}.obs;
                                  Navigator.pushNamed(
                                      context, DeliveryInstantScreen.routeName);
                                },
                                icon: Icon(Icons.flash_on_sharp),
                                label: Text('Instant')),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                                onPressed: () async {
                                  await SharedToken.univSetterString(
                                      'backToMenu',
                                      OutOfTownCargoScreen.routeName);
                                  final DeliveryFormController ctl =
                                      Get.put(DeliveryFormController());
                                  ctl.form = {}.obs;
                                  Navigator.pushNamed(
                                      context, OutOfTownCargoScreen.routeName);
                                },
                                icon: Icon(Icons.fire_truck),
                                label: Text('Out-of-Town Cargo')),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                                onPressed: () async {
                                  await SharedToken.univSetterString(
                                      'backToMenu',
                                      DeliveryPackageByWeightScreen.routeName);
                                  final DeliveryFormController ctl =
                                      Get.put(DeliveryFormController());
                                  ctl.form = {}.obs;
                                  Navigator.pushNamed(context,
                                      DeliveryPackageByWeightScreen.routeName);
                                },
                                icon: Icon(Icons.card_travel),
                                label: Text('Package Rate by Weight')),
                          )
                        ],
                      )
                    ],
                  ),
                  const OngoingDeliveryComponent()
                ],
              ),
              Column(
                children: [
                  TextFormField(
                    onChanged: (value) {
                      _debouncer.run(() {
                        print('Action after 0.5 seconds: $value');
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Order...', // Placeholder text
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 50,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Item $index'),
                          subtitle: Text('This is a dummy item.'),
                          leading:
                              const Icon(Icons.list), // Just for illustration
                          onTap: () {
                            Navigator.pushNamed(
                                context, SummaryOrderScreen.routeName);
                          },
                          trailing: Text('Completed',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
      ),
    );
  }
}
