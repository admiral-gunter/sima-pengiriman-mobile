import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
import '../daily_report_driver/daily_report_driver_screen.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'components/body.dart';
import 'components/body_select_customer.dart';

class MenuScreen extends StatefulWidget {
  static var routeName = '/menu';

  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final client = http.Client();

  Future _cekAbsensi() async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST', Uri.parse('${kURL_ORIGIN}cek-supir-km-insert-absen'));

    final username = await SharedToken.univGetterString('username');
    request.bodyFields = {'created_by': username};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var resp = await response.stream.bytesToString();
      // Decode the response body as JSON
      var jsonResp = jsonDecode(resp);

      // Access the 'msg' field from the JSON
      // print(jsonResp['msg']);

      if (jsonResp['msg'] == 'SUPIR_BELUM_ABSEN') {
        await SharedToken.univSetterString('STS_ABSEN', 'BELUM_ABSEN');

        if (!mounted) return;
        Navigator.pushReplacementNamed(
            context, DailyReportDriverScreen.routeName);
      } else {
        await SharedToken.univSetterString('STS_ABSEN', '');
        if (!mounted) return;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> checkTokenAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final uRole = await SharedToken.univGetterString('USER_ROLE');
    String? token = prefs.getString('token');
    if (!mounted) return;

    String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (token != null && uRole == 'USER_SENDER') {
      // print('retard');
      Navigator.pushReplacementNamed(context, DeliverOrderMenu.routeName);
      return;
    }

    if (token != null && currentRoute != MenuScreen.routeName) {
      Navigator.pushReplacementNamed(context, MenuScreen.routeName);
    } else if (token == null && currentRoute != SignInScreen.routeName) {
      await DatabaseHelper.instance.emptyAllTables();

      await SharedToken.tokenRemover();
      if (!mounted) return;

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
        // bool res = await openAppSettings();
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

  Future initFunc() async {
    try {
      await cekKoneksiAndLogoutIfOnline();
      await _cekAbsensi();
    } catch (e) {
      // print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // _backgroundServices();
    _addLokasiFirebaseFromLok('aa', 'aa');
    initFunc();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    SharedToken.univGetterString('last_login_dt').then((value) => {
          if (value != formattedDate)
            {Navigator.pushReplacementNamed(context, SignInScreen.routeName)}
        });
  }

  // CHECK CONNECTION
  Future cekKoneksiAndLogoutIfOnline() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) {
          checkTokenAndNavigate();
        }
      }
    } on SocketException catch (_) {
      if (mounted) {}
    }
  }

  // TEST CODE
  Future<void> _addLokasiFirebaseFromLok(String name, String email) async {
    final username = await SharedToken.univGetterString('username');
    final DatabaseReference dblokRef =
        FirebaseDatabase.instance.ref('sima-pengiriman/$username');
    try {
      await dblokRef.push().set({
        'name': name,
        'email': email,
      });

      // print('data added');
    } catch (e) {
      // print('Error adding user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Body(),
      // body: BodySelectCustomer(),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
