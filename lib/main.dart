import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/routes.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

void onStart(ServiceInstance serviceInstance) async {
  String username = await SharedToken.univGetterString('username');

  Timer.periodic(Duration(seconds: 20), (Timer timer) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final DatabaseReference dashboardLive =
        FirebaseDatabase.instance.ref('realtime_supir_dashboard/${username}');

    await dashboardLive.set({
      "lat": position.latitude.toString(),
      "long": position.longitude.toString()
    });

    // print('fumu ${position.latitude} ${position.longitude}');
  });
}

bool onBackground(ServiceInstance serviceInstance) {
  return true;
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onBackground,
    ),
  );
  service.startService();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeService();
  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme(),
      initialRoute: MenuScreen.routeName,
      routes: routes,
    );
  }
}
