import 'package:flutter/material.dart';
import 'package:sima_pengiriman/screens/sign_in/sign_in_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'profile_menu.dart';
import 'profile_pic.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ProfilePic(),
          SizedBox(height: 20),
          ProfileMenu(
            text: "My Account",
            icon: "assets/icons/User Icon.svg",
            press: () => {},
          ),
          ProfileMenu(
            text: "Notifications",
            icon: "assets/icons/Bell.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Settings",
            icon: "assets/icons/Settings.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Help Center",
            icon: "assets/icons/Question mark.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Log Out",
            icon: "assets/icons/Log out.svg",
            press: () async {
              DatabaseHelper.instance.emptyAllTables();
              // DatabaseHelper.instance.dropDatabase();
              await SharedToken.tokenRemover();
              Navigator.pushReplacementNamed(context, SignInScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
