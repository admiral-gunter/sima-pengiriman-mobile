import 'package:flutter/material.dart';
import 'package:sima_pengiriman/screens/delivery_order_menu/delivery_order_menu.dart';

import 'components/delivery_form.dart';

class DeliveryInstantScreen extends StatelessWidget {
  const DeliveryInstantScreen({super.key});
  static String routeName = "/delivery-instant";

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
        title: Text("Calculate Shipping"),
      ),
      body: Padding(padding: EdgeInsets.all(10), child: DeliveryForm()),
    );
  }
}
