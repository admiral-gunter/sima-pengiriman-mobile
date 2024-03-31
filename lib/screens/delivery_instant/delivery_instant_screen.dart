import 'package:flutter/material.dart';

import 'components/delivery_form.dart';

class DeliveryInstantScreen extends StatelessWidget {
  const DeliveryInstantScreen({super.key});
  static String routeName = "/delivery-instant";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculate Shipping"),
      ),
      body: Padding(padding: EdgeInsets.all(10), child: DeliveryForm()),
    );
  }
}
