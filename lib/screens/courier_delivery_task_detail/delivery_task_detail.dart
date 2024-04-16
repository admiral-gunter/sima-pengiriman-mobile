import 'package:flutter/material.dart';

import 'components/body.dart';

class DeliveryTaskDetail extends StatelessWidget {
  static String routeName = "/deliveryTaskDetail";
  const DeliveryTaskDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delivery Task Detail')),
      body: Body(),
    );
  }
}
