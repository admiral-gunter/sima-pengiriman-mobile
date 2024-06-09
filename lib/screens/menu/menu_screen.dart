import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sima_pengiriman/screens/delivery_order_menu/delivery_order_menu.dart';
import 'package:sima_pengiriman/screens/sign_in/sign_in_screen.dart';
import 'package:http/http.dart' as http;

import '../../components/coustom_bottom_nav_bar.dart';
import '../../constants.dart';
import '../../enums.dart';
import '../../helper/database_helper.dart';
import '../../shared_preferences/shared_token.dart';
import '../../size_config.dart';
import 'components/body.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MenuScreen extends StatefulWidget {
  static var routeName = '/menu';

  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final client = http.Client();

  Future<void> checkTokenAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final uRole = await SharedToken.univGetterString('USER_ROLE');
    String? token = prefs.getString('token');
    String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (token != null && uRole == 'USER_SENDER') {
      print('retard');
      Navigator.pushReplacementNamed(context, DeliverOrderMenu.routeName);
      return;
    }

    if (token != null && currentRoute != MenuScreen.routeName) {
      Navigator.pushReplacementNamed(context, MenuScreen.routeName);
    } else if (token == null && currentRoute != SignInScreen.routeName) {
      await DatabaseHelper.instance.emptyAllTables();

      await SharedToken.tokenRemover();
      Navigator.pushReplacementNamed(context, SignInScreen.routeName);
    }
  }

  void setPermissionHandler() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      var status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        var status = await Permission.locationAlways.request();
        if (status.isGranted) {
          //Do some stuff
        } else {
          //Do another stuff
        }
      } else {
        //The user deny the permission
      }
      if (status.isPermanentlyDenied) {
        //When the user previously rejected the permission and select never ask again
        //Open the screen of settings
        bool res = await openAppSettings();
      }
    } else {
      //In use is available, check the always in use
      var status = await Permission.locationAlways.status;
      if (!status.isGranted) {
        var status = await Permission.locationAlways.request();
        if (status.isGranted) {
          //Do some stuff
        } else {
          //Do another stuff
        }
      } else {
        //previously available, do some stuff or nothing
      }
    }
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _backgroundServices();
    _addLokasiFirebaseFromLok('aa', 'aa');
    checkTokenAndNavigate();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    SharedToken.univGetterString('last_login_dt').then((value) => {
          if (value != formattedDate)
            {Navigator.pushReplacementNamed(context, SignInScreen.routeName)}
        });
  }

  // TEST CODE
  Future<void> _addLokasiFirebaseFromLok(String name, String email) async {
    final username = await SharedToken.univGetterString('username');
    final DatabaseReference dblokRef =
        FirebaseDatabase.instance.ref('sima-pengiriman/${username}');
    try {
      await dblokRef.push().set({
        'name': name,
        'email': email,
      });

      print('data added');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

// TEST CODE
  _backgroundServices() async {
    try {
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "flutter_background example app",
        notificationText:
            "Background notification for keeping the example app running in the background",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(
            name: 'background_icon',
            defType: 'drawable'), // Default is ic_launcher from folder mipmap
      );
      await FlutterBackground.initialize(androidConfig: androidConfig);
      final eto = await FlutterBackground.enableBackgroundExecution();
      print('aaa jalan lo ${eto}');
    } catch (e) {
      print('error background: ${e}');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
