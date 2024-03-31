import 'package:flutter/material.dart';
import 'package:sima_pengiriman/components/coustom_bottom_nav_bar.dart';

import '../../enums.dart';
import '../delivery_instant/delivery_instant_screen.dart';

class DeliverOrderMenu extends StatelessWidget {
  const DeliverOrderMenu({super.key});

  static String routeName = "/delivery-order-menu";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Select Delivery"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
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
            Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                'See My Deliveries',
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
            )
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
