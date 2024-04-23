import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/components/coustom_bottom_nav_bar.dart';
import 'package:sima_pengiriman/screens/delivery_order_menu/components/ongoing_delivery_component.dart';
import 'package:sima_pengiriman/screens/history_turun_barang/history_turun_barang.dart';

import '../../enums.dart';
import '../../helper/debouncer.dart';
import '../delivery_instant/controllers/delivery_form_controller.dart';
import '../delivery_instant/delivery_instant_screen.dart';
import '../history_order/history_order_screen.dart';
import '../summary_order/summary_order_screen.dart';

class DeliverOrderMenu extends StatelessWidget {
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  DeliverOrderMenu({super.key});

  static String routeName = "/delivery-order-menu";
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Hi '),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Select Delivery'),
              Tab(text: 'History Order'),
            ],
          ),
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
                        Text('You Have 0 Deliveries today'),
                        SizedBox(
                          height: 20,
                        )
                      ]),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                                onPressed: () {
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
                                onPressed: () {},
                                icon: Icon(Icons.fire_truck),
                                label: Text('Out-of-Town Cargo')),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                                onPressed: () {},
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
