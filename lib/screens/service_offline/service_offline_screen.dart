import 'package:flutter/material.dart';
import 'components/body.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';

class ServiceOfflineScreen extends StatelessWidget {
  const ServiceOfflineScreen({Key? key}) : super(key: key);
  static String routeName = "/service-offline";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
            title: Text(
          "Service (Offline)",
          style: TextStyle(
            color: Colors
                .black, // Change this color to match your AppBar's background color.
          ),
        )),
      ),
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
