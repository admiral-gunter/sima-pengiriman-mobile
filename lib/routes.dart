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

import 'screens/barang_tidak_muat/barang_tidak_muat_screen.dart';
import 'screens/courier_delivery_task_detail/delivery_task_detail.dart';
import 'screens/courier_scanner/courier_scanner_screen.dart';
import 'screens/daily_report_driver/daily_report_driver_screen.dart';
import 'screens/delivery_instant/delivery_instant_screen.dart';
import 'screens/delivery_package_by_weight/delivery_package_by_weight_screen.dart';
import 'screens/history_order/history_order_screen.dart';
import 'screens/history_turun_barang/history_turun_barang.dart';
import 'screens/looking_for_courier/looking_for_courier.dart';
import 'screens/map_picker/map_picker.dart';
import 'screens/maps_view/maps_view.dart';
import 'screens/menu_select_customer/menu_select_customer.dart';
import 'screens/menu_sj_customer/menu_sj_customer_screen.dart';
import 'screens/order_delivery_screen/order_delivery_screen.dart';
import 'screens/order_service/components/order_service_scanner_sn.dart';
import 'screens/order_service/order_service_screen.dart';
import 'screens/out_of_town_cargo/out_of_town_cargo_screen.dart';
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
  MenuScreen.routeName: (context) => const MenuScreen(),
  ListBarcodesScreen.routeName: (context) => ListBarcodesScreen(),
  ScannerOfflineScreen.routeName: (context) => ScannerOfflineScreen(),
  TurunBarangOfflineScreen.routeName: (context) =>
      const TurunBarangOfflineScreen(),
  TurunBarangOnlineScreen.routeName: (context) =>
      const TurunBarangOnlineScreen(),
  ScanPengirimanScreen.routeName: (context) => const ScanPengirimanScreen(),
  HistoryBarangScreen.routeName: (context) => const HistoryBarangScreen(),
  TurunBarangOnlineHistoryScreen.routeName: (context) =>
      const TurunBarangOnlineHistoryScreen(),
  MapsView.routeName: (context) => const MapsView(),
  DeliverOrderMenu.routeName: (context) => DeliverOrderMenu(),
  DeliveryInstantScreen.routeName: (context) => const DeliveryInstantScreen(),
  MapPicker.routeName: (context) => const MapPicker(
        title: 'Map Picker',
      ),
  LookingForCourier.routeName: (context) => const LookingForCourier(),
  OrderDeliveryScreen.routeName: (context) => const OrderDeliveryScreen(),
  HistoryOrderScreen.routeName: (context) => const HistoryOrderScreen(),
  SummaryOrderScreen.routeName: (context) => SummaryOrderScreen(),
  DeliveryTaskDetail.routeName: (context) => const DeliveryTaskDetail(),
  CourierScannerScreen.routeName: (context) => const CourierScannerScreen(),
  OutOfTownCargoScreen.routeName: (context) => const OutOfTownCargoScreen(),
  DeliveryPackageByWeightScreen.routeName: (context) =>
      const DeliveryPackageByWeightScreen(),
  DailyReportDriverScreen.routeName: (context) =>
      const DailyReportDriverScreen(),
  BarangTidakMuatScreen.routeName: (context) => const BarangTidakMuatScreen(),
  OrderServiceScreen.routeName: (context) => const OrderServiceScreen(),
  OrderServiceScannerSnScreen.routeName: (context) =>
      const OrderServiceScannerSnScreen(),
  MenuSelectCustomer.routeName: (context) => const MenuSelectCustomer(),
  MenuSJCustomerScreen.routeName: (context) => const MenuSJCustomerScreen()
};
