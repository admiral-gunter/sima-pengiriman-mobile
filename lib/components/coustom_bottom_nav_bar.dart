import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sima_pengiriman/screens/daily_report_driver/daily_report_driver_screen.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/screens/order_service/order_service_screen.dart';
import 'package:sima_pengiriman/screens/profile/profile_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

import '../constants.dart';
import '../enums.dart';
import '../screens/delivery_order_menu/delivery_order_menu.dart';
import '../screens/menu_select_customer/menu_select_customer.dart';
import '../screens/order_delivery_screen/order_delivery_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    Key? key,
    required this.selectedMenu,
  }) : super(key: key);

  final MenuState selectedMenu;

  @override
  Widget build(BuildContext context) {
    final Color inActiveIconColor = Color(0xFFB6B6B6);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -15),
            blurRadius: 20,
            color: Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/Shop Icon.svg",
                    color: MenuState.home == selectedMenu
                        ? kPrimaryColor
                        : inActiveIconColor,
                  ),
                  onPressed: () async {
                    String? currentRoute =
                        ModalRoute.of(context)?.settings.name;

                    if (currentRoute != MenuScreen.routeName) {
                      final uRole =
                          await SharedToken.univGetterString('USER_ROLE');
                      if (uRole == 'USER_SENDER') {
                        Navigator.pushNamed(
                            context, DeliverOrderMenu.routeName);
                      } else {
                        Navigator.pushNamed(
                            context, MenuSelectCustomer.routeName);
                        // Navigator.pushNamed(context, MenuScreen.routeName);
                      }
                    }
                  }),
              IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/Bill Icon.svg",
                    color: MenuState.dailyReport == selectedMenu
                        ? kPrimaryColor
                        : inActiveIconColor,
                  ),
                  onPressed: () {
                    String? currentRoute =
                        ModalRoute.of(context)?.settings.name;

                    if (currentRoute != DailyReportDriverScreen.routeName) {
                      Navigator.pushNamed(
                          context, DailyReportDriverScreen.routeName);
                    }
                  }),
              IconButton(
                  icon: Icon(
                    Icons.add_box_rounded,
                    color: MenuState.orderService == selectedMenu
                        ? kPrimaryColor
                        : inActiveIconColor,
                  ),
                  onPressed: () {
                    String? currentRoute =
                        ModalRoute.of(context)?.settings.name;

                    if (currentRoute != OrderServiceScreen.routeName) {
                      Navigator.pushNamed(
                          context, OrderServiceScreen.routeName);
                    }
                  }),
              IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/User Icon.svg",
                    color: MenuState.profile == selectedMenu
                        ? kPrimaryColor
                        : inActiveIconColor,
                  ),
                  onPressed: () {
                    String? currentRoute =
                        ModalRoute.of(context)?.settings.name;

                    if (currentRoute != ProfileScreen.routeName) {
                      Navigator.pushNamed(context, ProfileScreen.routeName);
                    }
                  }),
            ],
          )),
    );
  }
}
