import 'package:flutter/material.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';

import 'components/body.dart';

class DeliveryTaskDetail extends StatelessWidget {
  static String routeName = "/deliveryTaskDetail";
  const DeliveryTaskDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Task Detail'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Custom back button logic
            Navigator.pushReplacementNamed(context, MenuScreen.routeName);
          },
        ),
      ),
      body: Body(),
    );
  }
}
