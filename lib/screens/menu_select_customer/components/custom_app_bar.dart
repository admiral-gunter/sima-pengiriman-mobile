import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared_preferences/shared_token.dart';
import '../controllers/menu_select_customer_controller.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  // final String title;

  @override
  CustomAppBarState createState() => CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBarState extends State<CustomAppBar> {
  bool hasInternet = false;
  Timer? _internetCheckTimer;
  String username = '';

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _internetCheckTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      checkInternetConnection();
    });

    SharedToken.univGetterString('username').then((value) {
      setState(() {
        username = value;
      });
    });
  }

  @override
  void dispose() {
    _internetCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> checkInternetConnection() async {
    bool previousStatus = hasInternet;
    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!previousStatus && mounted) {
          setState(() {
            hasInternet = true;
          });
        }
      }
    } on SocketException catch (_) {
      if (previousStatus && mounted) {
        setState(() {
          hasInternet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text('Hi $username'), // Access the widget properties with `widget`
      leading: IconButton(
        icon:
            Icon(Icons.circle, color: hasInternet ? Colors.green : Colors.red),
        onPressed: () {
          setState(() {});
        },
      ),
    );
  }
}
