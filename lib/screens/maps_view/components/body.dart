import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

const LatLng SOURCE_LOCATION = LatLng(13.652720, 100.493635);
const LatLng DEST_LOCATION = LatLng(13.6640896, 100.4357021);

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
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      // do what you want to do with the position here
      setState(() {
        currentLocation = LatLng(position!.latitude, position!.longitude);

        if (SOURCE_LOCATION.latitude != currentLocation.latitude &&
            SOURCE_LOCATION.longitude != currentLocation.longitude) {
          _markers
              .removeWhere((marker) => marker.markerId.value == 'sourcePin');
          _markers.add(Marker(
            markerId: MarkerId('sourcePin'),
            position: currentLocation!,
            icon: BitmapDescriptor.defaultMarker,
          ));
        }
        // _markers.removeWhere((marker) => marker.markerId.value == 'sourcePin');
        // _markers.add(Marker(
        //   markerId: MarkerId('sourcePin'),
        //   position: currentLocation!,
        //   icon: BitmapDescriptor.defaultMarker,
        // ));
      });
    });
  }

  void setInitialLocation() {
    currentLocation =
        LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude);
    destinationLocation =
        LatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Direction"),
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        compassEnabled: false,
        tiltGesturesEnabled: false,
        polylines: _polylines,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          mapController.complete(controller);

          showMarker();
          setPolylines();
        },
        initialCameraPosition: CameraPosition(
          target: SOURCE_LOCATION,
          zoom: 13,
        ),
      ),
    );
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
            color: Color.fromARGB(255, 0, 43, 11),
            points: polylineCoordinates));
      });
    }
  }
}
