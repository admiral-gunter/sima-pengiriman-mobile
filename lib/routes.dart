import 'package:flutter/widgets.dart';
import 'package:sima_pengiriman/screens/cart/cart_screen.dart';
import 'package:sima_pengiriman/screens/complete_profile/complete_profile_screen.dart';
import 'package:sima_pengiriman/screens/forgot_password/forgot_password_screen.dart';
import 'package:sima_pengiriman/screens/form_tap/form_tap_screen.dart';
import 'package:sima_pengiriman/screens/grosir_tap_out/grosir_tap_out.dart';
import 'package:sima_pengiriman/screens/list_barcodes/list_barcodes_screen.dart';
import 'package:sima_pengiriman/screens/purchase_order/purchase_order_screen.dart';
import 'package:sima_pengiriman/screens/login_success/login_success_screen.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/screens/otp/otp_screen.dart';
import 'package:sima_pengiriman/screens/pindah_gudang_offline/pindah_gudang_offline_screen.dart';
import 'package:sima_pengiriman/screens/profile/profile_screen.dart';
import 'package:sima_pengiriman/screens/retail_tap_out/retail_tap_out_screen.dart';
import 'package:sima_pengiriman/screens/scanner/scanner_screen.dart';
import 'package:sima_pengiriman/screens/service_offline/service_offline_screen.dart';
import 'package:sima_pengiriman/screens/sign_in/sign_in_screen.dart';
import 'package:sima_pengiriman/screens/splash/splash_screen.dart';
import 'package:sima_pengiriman/screens/turun_barang_offline/turun_barang_offline_screen.dart';
import 'package:sima_pengiriman/screens/universal_scannner/controller/universal_scanner_data.dart';

import 'screens/purchase_order_offline/purchase_order_offline_screen.dart';
import 'screens/scan_pengiriman/scan_pengiriman_screen.dart';
import 'screens/scanner_offline/scanner_offline_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/turun_barang_online/turun_barang_online.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
  OtpScreen.routeName: (context) => OtpScreen(),
  CartScreen.routeName: (context) => CartScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  ScannerScreen.routeName: (context) => ScannerScreen(),
  MenuScreen.routeName: (context) => MenuScreen(),
  ListBarcodesScreen.routeName: (context) => ListBarcodesScreen(),
  FormTapScreen.routeName: (context) => FormTapScreen(),
  ListPoScreen.routeName: (context) => ListPoScreen(),
  PurchaseOrderOfflineScreen.routeName: (context) =>
      PurchaseOrderOfflineScreen(),
  ScannerOfflineScreen.routeName: (context) => ScannerOfflineScreen(),
  ServiceOfflineScreen.routeName: (context) => ServiceOfflineScreen(),
  '/pindah-gudang-offline-terima': (context) =>
      PindahGudangOfflineScreen(tipe: 'terima'),
  '/pindah-gudang-offline-keluar': (context) =>
      PindahGudangOfflineScreen(tipe: 'keluar'),
  GrosirTapOut.routeName: (context) => GrosirTapOut(),
  RetailTapOutScreen.routeName: (context) => RetailTapOutScreen(),
  TurunBarangOfflineScreen.routeName: (context) => TurunBarangOfflineScreen(),
  TurunBarangOnlineScreen.routeName: (context) => TurunBarangOnlineScreen(),
  ScanPengirimanScreen.routeName: (context) => ScanPengirimanScreen()
};
