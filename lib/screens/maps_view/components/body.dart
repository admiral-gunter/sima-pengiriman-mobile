import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sima_pengiriman/screens/maps_view/controllers/maps_view_controller.dart';
import 'package:uuid/uuid.dart';

import '../../../shared_preferences/shared_token.dart';

LatLng SOURCE_LOCATION = LatLng(-6.9466, 107.7299);
LatLng DEST_LOCATION = LatLng(-6.9098, 107.6084);

class Direction extends StatefulWidget {
  @override
  _DirectionState createState() => _DirectionState();
}

class _DirectionState extends State<Direction> {
  Completer<GoogleMapController> mapController = Completer();

  Set<Marker> _markers = Set<Marker>();
  late LatLng currentLocation;
  late LatLng destinationLocation;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    this.setInitialLocation();
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
      // do what you want to do with the position here
      setState(() async {
        // currentLocation = LatLng(position!.latitude, position!.longitude);
        await _addLokasiFirebaseFromLok(position!);
      });
    }, onError: (error) {
      print("Error getting location: $error");
      // Handle error appropriately
    });
  }

  void setInitialLocation() {
    // currentLocation =
    //     LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude);
    // destinationLocation =
    //     LatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude);
    final MapsViewController ctl = MapsViewController();

    final liveLokRefData = ctl.liveLokRefData;
    double latSource = ctl.liveLokRefData['lat_source'] as double;
    double longSource = ctl.liveLokRefData['long_source'] as double;

    double destLatSource = ctl.liveLokRefData['lat_dest'] as double;
    double destLongSource = ctl.liveLokRefData['long_dest'] as double;

    currentLocation = LatLng(latSource, longSource);
    destinationLocation = LatLng(destLatSource, destLongSource);
  }

  Future<void> _addLokasiFirebaseFromLok(Position currentPosition) async {
    DateTime timestamp = DateTime.now();

    String curTimeStamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);

    var uuid = Uuid();
    String username = await SharedToken.univGetterString('username');
    username = username.replaceAll(' ', '_');
    String timestampLink = DateFormat('dd-MM-yyyy').format(timestamp);

    // final String userId = username.toString() + '_' + uuid.v4().toString();
    final DatabaseReference dblokRef =
        FirebaseDatabase.instance.ref('sima_pengiriman_supir');

    // final String username = await SharedToken.univGetterString('username');

    final DatabaseReference livelokRef = FirebaseDatabase.instance
        .ref('perjalanan_supir_${username}_${timestampLink}');
    final MapsViewController ctl = MapsViewController();
    try {
      final liveLokRefData = ctl.liveLokRefData;
      double latSource = ctl.liveLokRefData['lat_source'] as double;
      double longSource = ctl.liveLokRefData['long_source'] as double;

      double destLatSource = ctl.liveLokRefData['lat_dest'] as double;
      double destLongSource = ctl.liveLokRefData['long_dest'] as double;

      currentLocation = LatLng(latSource, longSource);
      destinationLocation = LatLng(destLatSource, destLongSource);

      liveLokRefData['lat_cur'] = currentPosition.latitude;
      liveLokRefData['long_cur'] = currentPosition.longitude;
      liveLokRefData['updated_at'] = curTimeStamp;

      await livelokRef.set(liveLokRefData);

      await dblokRef.push().set({
        'created_at': curTimeStamp,
        'supir': username,
        'cur_long': currentPosition.longitude,
        'cur_lat': currentPosition.latitude,
        'id': uuid.v4()
      });

      // BODY PERJALANAN SUPIR FORMAT : perjalanan_supir_nama_HARI-TANGGAL-BULAN-TAHUN
      // "perjalanan_supir_sima": {
      //   "lat_cur": -6.9466,
      //   "lat_dest": "",
      //   "lat_source": -6.9465,
      //   "long_cur": 107.7299,
      //   "long_dest": "",
      //   "long_source": ""
      // },

      print('User added successfully!');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GoogleMap(
      myLocationEnabled: true,
      compassEnabled: false,
      tiltGesturesEnabled: false,
      polylines: _polylines,
      markers: _markers,
      trafficEnabled: bool.fromEnvironment("true"),
      onMapCreated: (GoogleMapController controller) {
        mapController.complete(controller);

        showMarker();
        setPolylines();
      },
      initialCameraPosition: CameraPosition(
        target: currentLocation,
        zoom: 13,
      ),
    ));
  }

  void showMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarker,
      ));

      _markers.add(Marker(
        markerId: MarkerId('destinationPin'),
        position: destinationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(90),
      ));
    });
  }

  void setPolylines() async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          "AIzaSyAuTc1cEdpSMnqduAMMAdtNAzp2jiE5Kdw",
          PointLatLng(currentLocation.latitude, currentLocation.longitude),
          PointLatLng(
              destinationLocation.latitude, destinationLocation.longitude));

      if (result.status == 'OK') {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        setState(() {
          _polylines.add(Polyline(
              width: 10,
              polylineId: PolylineId('polyLine'),
              color: Color.fromARGB(255, 255, 166, 0),
              points: polylineCoordinates));
        });
      } else {
        // Handle other status codes if needed
        print("Error: ${result.status}");
      }
    } catch (e) {
      // Handle any exceptions that occur during the execution
      print("Error: $e");
      // You can also show a user-friendly error message here if needed
    }
  }
}
