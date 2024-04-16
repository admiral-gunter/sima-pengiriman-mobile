import 'package:flutter/widgets.dart';
import 'package:sima_pengiriman/screens/complete_profile/complete_profile_screen.dart';
import 'package:sima_pengiriman/screens/delivery_order_menu/delivery_order_menu.dart';
import 'package:sima_pengiriman/screens/list_barcodes/list_barcodes_screen.dart';
import 'package:sima_pengiriman/screens/login_success/login_success_screen.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/screens/profile/profile_screen.dart';
import 'package:sima_pengiriman/screens/sign_in/sign_in_screen.dart';
import 'package:sima_pengiriman/screens/splash/splash_screen.dart';
import 'package:sima_pengiriman/screens/turun_barang_offline/turun_barang_offline_screen.dart';

import 'screens/courier_delivery_task_detail/delivery_task_detail.dart';
import 'screens/delivery_instant/delivery_instant_screen.dart';
import 'screens/history_order/history_order_screen.dart';
import 'screens/history_turun_barang/history_turun_barang.dart';
import 'screens/looking_for_courier/looking_for_courier.dart';
import 'screens/map_picker/map_picker.dart';
import 'screens/maps_view/maps_view.dart';
import 'screens/order_delivery_screen/order_delivery_screen.dart';
import 'screens/scan_pengiriman/scan_pengiriman_screen.dart';
import 'screens/scanner_offline/scanner_offline_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/summary_order/summary_order_screen.dart';
import 'screens/turun_barang_online/turun_barang_online.dart';
import 'screens/turun_barang_online/turun_barang_online_history.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  LoginSuccessScreen.routeName: (context) => LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  MenuScreen.routeName: (context) => MenuScreen(),
  ListBarcodesScreen.routeName: (context) => ListBarcodesScreen(),
  ScannerOfflineScreen.routeName: (context) => ScannerOfflineScreen(),
  TurunBarangOfflineScreen.routeName: (context) => TurunBarangOfflineScreen(),
  TurunBarangOnlineScreen.routeName: (context) => TurunBarangOnlineScreen(),
  ScanPengirimanScreen.routeName: (context) => ScanPengirimanScreen(),
  HistoryBarangScreen.routeName: (context) => HistoryBarangScreen(),
  TurunBarangOnlineHistoryScreen.routeName: (context) =>
      TurunBarangOnlineHistoryScreen(),
  MapsView.routeName: (context) => MapsView(),
  DeliverOrderMenu.routeName: (context) => DeliverOrderMenu(),
  DeliveryInstantScreen.routeName: (context) => DeliveryInstantScreen(),
  MapPicker.routeName: (context) => MapPicker(
        title: 'Map Picker',
      ),
  LookingForCourier.routeName: (context) => LookingForCourier(),
  OrderDeliveryScreen.routeName: (context) => OrderDeliveryScreen(),
  HistoryOrderScreen.routeName: (context) => HistoryOrderScreen(),
  SummaryOrderScreen.routeName: (context) => SummaryOrderScreen(),
  DeliveryTaskDetail.routeName: (context) => DeliveryTaskDetail()
};
