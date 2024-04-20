import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:sima_pengiriman/screens/delivery_instant/components/delivery_form.dart';

import '../../shared_preferences/shared_token.dart';
import '../delivery_instant/controllers/delivery_form_controller.dart';
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
  String typePickup = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      if (mounted) {
        typePickup = await SharedToken.univGetterString('type_pickup');
      }
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Update the UI with the current position
      setState(() {
        if (mounted) {
          _currentPosition = position;
        }
      });
    } catch (e) {
      // Handle any errors that occur during the process
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DeliveryFormController ctl = Get.put(DeliveryFormController());
    return Scaffold(
        appBar: AppBar(
          title: Text(typePickup.replaceAll('_', ' ')),
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
                locationPinText: '',
                center: LatLong(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                buttonTextStyle:
                    const TextStyle(fontSize: 18, fontStyle: FontStyle.normal),
                buttonColor: Colors.blue,
                buttonText: 'Set Current Location',
                onPicked: (pickedData) async {
                  if (typePickup == 'pickup_location') {
                    ctl.form['customer_address'] = pickedData.addressName;
                  }

                  if (typePickup == 'pickup_destination') {
                    ctl.form['destination_address'] = pickedData.addressName;
                  }
                  Navigator.pushReplacementNamed(
                      context, DeliveryInstantScreen.routeName);
                  // print(pickedData.latLong.latitude);
                  // print(pickedData.latLong.longitude);
                  // print(pickedData.address);
                  // print(pickedData.addressName);
                },
              ));
  }
}
