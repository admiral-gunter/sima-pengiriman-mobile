import 'package:flutter/material.dart';
import '../delivery_order_menu/delivery_order_menu.dart';
import 'components/body.dart';

class OutOfTownCargoScreen extends StatelessWidget {
  const OutOfTownCargoScreen({super.key});
  static String routeName = "/delivery-cargo";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, DeliverOrderMenu.routeName);
          },
        ),
        title: Text("Calculate Shipping (Cargo)"),
      ),
      body: Padding(padding: EdgeInsets.all(10), child: Body()),
    );
  }
}
