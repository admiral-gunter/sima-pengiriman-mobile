import 'package:flutter/material.dart';
import './components/body.dart';

class BarangTidakMuatScreen extends StatelessWidget {
  const BarangTidakMuatScreen({super.key});
  static var routeName = '/barang-tidak-muat-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
