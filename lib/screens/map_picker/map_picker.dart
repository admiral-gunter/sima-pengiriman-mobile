import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:sima_pengiriman/screens/delivery_instant/components/delivery_form.dart';

import '../delivery_instant/delivery_instant_screen.dart';

class MapPicker extends StatefulWidget {
  const MapPicker({Key? key, required this.title}) : super(key: key);
  static String routeName = "/map-picker";

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MapPicker> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapPicker> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Update the UI with the current position
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle any errors that occur during the process
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, DeliveryInstantScreen.routeName);
            },
          ),
        ),
        body: _currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : OpenStreetMapSearchAndPick(
                center: LatLong(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                buttonTextStyle:
                    const TextStyle(fontSize: 18, fontStyle: FontStyle.normal),
                buttonColor: Colors.blue,
                buttonText: 'Set Current Location',
                onPicked: (pickedData) {
                  print(pickedData.latLong.latitude);
                  print(pickedData.latLong.longitude);
                  print(pickedData.address);
                  print(pickedData.addressName);
                },
              ));
  }
}
