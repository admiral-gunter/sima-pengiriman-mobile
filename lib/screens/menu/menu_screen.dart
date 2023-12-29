import 'dart:convert';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class MenuScreen extends StatefulWidget {
  static var routeName = '/menu';

  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final client = http.Client();

  Future<void> checkTokenAndNavigate() async {
    // Get the SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the token value
    String? token = prefs.getString('token');
    String? currentRoute = ModalRoute.of(context)?.settings.name;

    // Check if the token exists
    if (token != null && currentRoute != MenuScreen.routeName) {
      // Token exists, redirect to another page
      Navigator.pushReplacementNamed(context, MenuScreen.routeName);
    } else if (token == null && currentRoute != SignInScreen.routeName) {
      await SharedToken.tokenRemover();
      // Token does not exist, stay on the current page or redirect to a login page
      Navigator.pushReplacementNamed(context, SignInScreen.routeName);
    }
  }

  Future<void> initData() async {
    try {
      final token = await SharedToken.tokenGetter();
      final companyId = await SharedToken.companyGetter();

      var param = '?field=select2_gudang&tipe=1';
      var url = Uri.parse(
          '${kURL_ORIGIN}select2/get-raw/${companyId}/${token!}${param}');

      var response = await http.post(url);

      var res = jsonDecode(response.body);
      await DatabaseHelper.instance.insertDatainventoryLocation(res);

      //http://localhost/grobx2023/api/sale-wholesale-customer/get/3/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTaW1hIiwiYXVkIjoiU2ltYSIsImlhdCI6MTY5MzY2NzQ2NCwidXNlcm5hbWUiOiJTaW1hIn0.nMfOLRkDkWLgr4cMkup5Gq0DSU6AtvVMyGTPYL70kIs?draw=1&columns[0][data]&columns[0][name]&columns[0][searchable]=true&columns[0][orderable]=false&columns[0][search][value]&columns[0][search][regex]=false&columns[1][data]&columns[1][name]&columns[1][searchable]=true&columns[1][orderable]=false&columns[1][search][value]&columns[1][search][regex]=false&columns[2][data]=email&columns[2][name]&columns[2][searchable]=true&columns[2][orderable]=false&columns[2][search][value]&columns[2][search][regex]=false&columns[3][data]=mobile&columns[3][name]&columns[3][searchable]=true&columns[3][orderable]=false&columns[3][search][value]&columns[3][search][regex]=false&columns[4][data]=status&columns[4][name]&columns[4][searchable]=true&columns[4][orderable]=false&columns[4][search][value]&columns[4][search][regex]=false&columns[5][data]=date_added&columns[5][name]&columns[5][searchable]=true&columns[5][orderable]=false&columns[5][search][value]&columns[5][search][regex]=false&columns[6][data]&columns[6][name]&columns[6][searchable]=true&columns[6][orderable]=false&columns[6][search][value]&columns[6][search][regex]=false&start=0&length=999999&search[value]&search[regex]=false
      url = Uri.parse(
          '${kURL_ORIGIN}sale-wholesale-customer/get/${companyId}/${token}?draw=1&columns[0][data]&columns[0][name]&columns[0][searchable]=true&columns[0][orderable]=false&columns[0][search][value]&columns[0][search][regex]=false&columns[1][data]&columns[1][name]&columns[1][searchable]=true&columns[1][orderable]=false&columns[1][search][value]&columns[1][search][regex]=false&columns[2][data]=email&columns[2][name]&columns[2][searchable]=true&columns[2][orderable]=false&columns[2][search][value]&columns[2][search][regex]=false&columns[3][data]=mobile&columns[3][name]&columns[3][searchable]=true&columns[3][orderable]=false&columns[3][search][value]&columns[3][search][regex]=false&columns[4][data]=status&columns[4][name]&columns[4][searchable]=true&columns[4][orderable]=false&columns[4][search][value]&columns[4][search][regex]=false&columns[5][data]=date_added&columns[5][name]&columns[5][searchable]=true&columns[5][orderable]=false&columns[5][search][value]&columns[5][search][regex]=false&columns[6][data]&columns[6][name]&columns[6][searchable]=true&columns[6][orderable]=false&columns[6][search][value]&columns[6][search][regex]=false&start=0&length=999999&search[value]&search[regex]=false');
      response = await http.post(url);
      res = jsonDecode(response.body);
      await DatabaseHelper.instance.insertDataCustomer(res['data']);
    } catch (e) {
      // await SharedToken.tokenRemover();
      // Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      print('ERROR following: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[800],
          content: Text(
              'Token Expired. To continue, please log out and log back in'),
        ),
      );
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
    checkTokenAndNavigate();
    // initData();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    SharedToken.univGetterString('last_login_dt').then((value) => {
      if(value != formattedDate){
        Navigator.pushReplacementNamed(context, SignInScreen.routeName)
      }
    });
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
