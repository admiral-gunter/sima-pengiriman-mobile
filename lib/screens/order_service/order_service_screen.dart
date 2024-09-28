import 'package:flutter/material.dart';
import 'package:sima_pengiriman/screens/barang_tidak_muat/components/body.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';

class OrderServiceScreen extends StatelessWidget {
  const OrderServiceScreen({super.key});
  static String routeName = "/order-service";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Order Service"),
      ),
      body: Padding(padding: EdgeInsets.all(10), child: Body()),
      bottomNavigationBar:
          CustomBottomNavBar(selectedMenu: MenuState.orderDelivery),
    );
    ;
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body:  Body(),

  //   )
  // }
}
