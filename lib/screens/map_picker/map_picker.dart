import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:sima_pengiriman/screens/delivery_instant/components/delivery_form.dart';

import '../../shared_preferences/shared_token.dart';
import '../delivery_instant/controllers/delivery_form_controller.dart';
import '../delivery_instant/delivery_instant_screen.dart';
import 'dart:math';

class MapPicker extends StatefulWidget {
  const MapPicker({Key? key, required this.title}) : super(key: key);
  static String routeName = "/map-picker";
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

      setState(() {
        if (mounted) {
          _currentPosition = position;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // Function to convert degrees to radians
  double degToRad(double deg) {
    return deg * (pi / 180);
  }

// Function to calculate distance using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers

    // Convert latitude and longitude from degrees to radians
    lat1 = degToRad(lat1);
    lon1 = degToRad(lon1);
    lat2 = degToRad(lat2);
    lon2 = degToRad(lon2);

    // Calculate differences in latitude and longitude
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    // Apply Haversine formula
    double a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  @override
  Widget build(BuildContext context) {
    final DeliveryFormController ctl = Get.put(DeliveryFormController());
    return Scaffold(
        appBar: AppBar(
          title: Text(typePickup.replaceAll('_', ' ')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final ruteBack = await SharedToken.univGetterString('backToMenu');
              Navigator.pushReplacementNamed(context, ruteBack);
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
                  double lat1 = -6.920809;
                  double lon1 = 107.604087;
                  if (typePickup == 'pickup_location') {
                    double distance = calculateDistance(
                        lat1,
                        lon1,
                        pickedData.latLong.latitude,
                        pickedData.latLong.longitude);

                    if (distance > 20 &&
                        ctl.form['delivery_type'] == 'INSTANT') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Instant tidak bisa melebihi kota bandung'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    ctl.form['pickup_address'] = pickedData.addressName;

                    ctl.form['pickup_lat'] = pickedData.latLong.latitude;
                    ctl.form['pickup_long'] = pickedData.latLong.longitude;
                  }

                  if (typePickup == 'pickup_destination') {
                    double distance = calculateDistance(
                        lat1,
                        lon1,
                        pickedData.latLong.latitude,
                        pickedData.latLong.longitude);
                    if (distance > 20 &&
                        ctl.form['delivery_type'] == 'INSTANT') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Instant tidak bisa melebihi kota bandung'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    ctl.form['destination_address'] = pickedData.addressName;

                    ctl.form['destination_lat'] = pickedData.latLong.latitude;
                    ctl.form['destination_long'] = pickedData.latLong.longitude;
                  }
                  final ruteBack =
                      await SharedToken.univGetterString('backToMenu');
                  Navigator.pushReplacementNamed(context, ruteBack);
                  // print(pickedData.latLong.latitude);
                  // print(pickedData.latLong.longitude);
                  // print(pickedData.address);
                  // print(pickedData.addressName);
                },
              ));
  }
}
