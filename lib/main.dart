import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sima_pengiriman/helper/firebase_api.dart';
import 'package:sima_pengiriman/routes.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants.dart';
import 'firebase_options.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import 'helper/dependency_injection.dart';

void onStart(ServiceInstance serviceInstance) async {
  String username = await SharedToken.univGetterString('username');
  username = username.replaceAll(' ', '_');

  Timer.periodic(Duration(seconds: 10), (Timer timer) async {
    print('aaa');
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
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
      "long": position.longitude.toString(),
      "updated_at": formattedDate
    });
  });

  Timer.periodic(Duration(seconds: 30), (Timer timer) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    DateTime now = DateTime.now();
    String yMd = DateFormat('yyyy-MM-dd').format(now);
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final DatabaseReference dashboardLive = FirebaseDatabase.instance
        .ref('supir_activity_log/${username}/${formattedDate}');

    await dashboardLive.set({
      "lat": position.latitude.toString(),
      "long": position.longitude.toString(),
      "created_at": formattedDate
    });
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
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  await FirebaseApi().initNotifications();

  // await initializeService();
  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
  DependencyInjection.init();
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
