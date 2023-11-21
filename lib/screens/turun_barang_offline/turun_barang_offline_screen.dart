import 'package:flutter/material.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'package:location/location.dart';

import '../turun_barang_online/controllers/turun_barang_online_controller.dart';

class TurunBarangOfflineScreen extends StatefulWidget {
  const TurunBarangOfflineScreen({Key? key}) : super(key: key);
  static String routeName = "/turun-barang-online";

  @override
  State<TurunBarangOfflineScreen> createState() =>
      _TurunBarangOfflineScreenState();
}

class _TurunBarangOfflineScreenState extends State<TurunBarangOfflineScreen> {
  Location location = Location();

  late double latitude;

  late double longitude;

  @override
  void initState() {
    super.initState();
    _getLocationData();
  }

  _getLocationData() async {
    try {
      LocationData locationData = await location.getLocation();
      setState(() {
        latitude = locationData.latitude!;
        longitude = locationData.longitude!;
      });
    } catch (e) {
      // Handle errors, such as permissions or location services not enabled.
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
            title: Text(
          "Turun Barang (Offline)",
          style: TextStyle(
            color: Colors
                .black, // Change this color to match your AppBar's background color.
          ),
        )),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            TextFormField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: 'Input Nomor OG',
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                ),
              ),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
              ),
            ),
            TextFormField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: 'Customer',
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                ),
              ),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
