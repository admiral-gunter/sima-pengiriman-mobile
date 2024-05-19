import 'package:flutter/material.dart';

import './components/body.dart';
import '../delivery_order_menu/delivery_order_menu.dart';

class DeliveryPackageByWeightScreen extends StatelessWidget {
  const DeliveryPackageByWeightScreen({super.key});

  static String routeName = "/delivery-by-weight";

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
        title: Text("Package by Weight"),
      ),
      body: Padding(padding: EdgeInsets.all(10), child: Body()),
    );
  }
}
