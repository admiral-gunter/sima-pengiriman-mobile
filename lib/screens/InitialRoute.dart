import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu/menu_screen.dart';
import 'sign_in/sign_in_screen.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _getToken() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<SharedPreferences>(
        future: _getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the future to complete, show a loading screen
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            // If token exists in shared preferences, return MenuScreen
            if (snapshot.data!.containsKey('token')) {
              return MenuScreen();
            } else {
              // Otherwise, return SignInScreen
              return SignInScreen();
            }
          } else if (snapshot.hasError) {
            // If an error occurred, display an error message
            return Text('Error: ${snapshot.error}');
          } else {
            // If no data available, show a default screen
            return Container();
          }
        },
      ),
    );
  }
}
