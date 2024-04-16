import 'package:flutter/material.dart';
import 'package:sima_pengiriman/components/default_button.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/size_config.dart';

import '../../../shared_preferences/shared_token.dart';
import '../../delivery_order_menu/delivery_order_menu.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: SizeConfig.screenHeight * 0.04),
        Image.asset(
          "assets/images/success.png",
          height: SizeConfig.screenHeight * 0.4, //40%
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.08),
        Text(
          "Login Success",
          style: TextStyle(
            fontSize: getProportionateScreenWidth(30),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Spacer(),
        SizedBox(
          width: SizeConfig.screenWidth * 0.6,
          child: DefaultButton(
            text: "Back to home",
            press: () async {
              String uname = await SharedToken.univGetterString('username');
              if (uname == 'sima') {
                Navigator.pushReplacementNamed(
                    context, DeliverOrderMenu.routeName);
              } else {
                Navigator.pushReplacementNamed(context, MenuScreen.routeName);
              }
            },
          ),
        ),
        Spacer(),
      ],
    );
  }
}
