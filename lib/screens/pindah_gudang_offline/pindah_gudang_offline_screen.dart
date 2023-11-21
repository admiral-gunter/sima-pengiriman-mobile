import 'package:flutter/material.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'components/body.dart';

class PindahGudangOfflineScreen extends StatelessWidget {
  PindahGudangOfflineScreen({Key? key, required this.tipe}) : super(key: key);
  static String routeName = '/pindah-gudang-offline';
  final String tipe;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          title: Text(
            "Pindah Gudang (Offline)",
            style: TextStyle(
              color: Colors
                  .black, // Change this color to match your AppBar's background color.
            ),
          ),
        ),
      ),
      body: Body(tipe: tipe),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
