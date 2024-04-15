import 'package:flutter/material.dart';
import 'package:sima_pengiriman/components/coustom_bottom_nav_bar.dart';
import 'package:sima_pengiriman/screens/history_turun_barang/history_turun_barang.dart';

import '../../enums.dart';
import '../../helper/debouncer.dart';
import '../delivery_instant/delivery_instant_screen.dart';
import '../history_order/history_order_screen.dart';
import '../summary_order/summary_order_screen.dart';

class DeliverOrderMenu extends StatelessWidget {
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));
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
          bottom: TabBar(
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
                  Column(
                    children: [
                      Text(
                        'Ongoing Delivery',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: 50,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Item $index'),
                              subtitle: Text('This is a dummy item.'),
                              leading: const Icon(
                                  Icons.list), // Just for illustration
                              onTap: () {
                                Navigator.pushNamed(
                                    context, SummaryOrderScreen.routeName);
                                print('Tapped on item $index');
                              },
                            );
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, HistoryOrderScreen.routeName);
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

                            borderRadius: BorderRadius.circular(
                                20), // Adjust the value as needed
                          ),
                        ),
                      )
                    ],
                  )
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
                            print('Tapped on item $index');
                          },
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
