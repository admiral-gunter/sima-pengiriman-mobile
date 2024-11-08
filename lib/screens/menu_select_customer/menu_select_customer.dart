import 'package:flutter/material.dart';
import 'package:overlay_kit/overlay_kit.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import '../../size_config.dart';
import 'components/body.dart';
import 'components/custom_app_bar.dart';

class MenuSelectCustomer extends StatelessWidget {
  static String routeName = '/menu-select-customer';
  const MenuSelectCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return OverlayKit(
      child: const Scaffold(
        appBar: CustomAppBar(),
        body: Body(),
        bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
      ),
    );
  }
}
