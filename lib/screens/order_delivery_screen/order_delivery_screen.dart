import 'package:flutter/material.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'components/body.dart';

class OrderDeliveryScreen extends StatelessWidget {
  static String routeName = '/orderDelivery';
  const OrderDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Order Delivery"),
      ),
      body: Padding(padding: EdgeInsets.all(10), child: Body()),
      bottomNavigationBar:
          CustomBottomNavBar(selectedMenu: MenuState.orderDelivery),
    );
    ;
  }
}
