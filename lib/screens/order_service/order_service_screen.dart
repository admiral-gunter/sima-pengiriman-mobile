import 'package:flutter/material.dart';
// import 'package:sima_pengiriman/screens/barang_tidak_muat/components/body.dart';
import './components/body.dart';
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
        title: const Text("Order Service"),
      ),
      body: const Padding(padding: EdgeInsets.all(10), child: Body()),
      bottomNavigationBar:
          const CustomBottomNavBar(selectedMenu: MenuState.orderDelivery),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body:  Body(),

  //   )
  // }
}
