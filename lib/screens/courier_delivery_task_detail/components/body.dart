import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/screens/courier_scanner/courier_scanner_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';
import '../../../shared_preferences/shared_token.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  File? _imageFile;

  Future<void> _takePicture() async {
    final imagePicker = ImagePicker();

    var pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    setState(() async {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);

        await _uploadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      print('No image selected.');
      return;
    }

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://your-api-endpoint.com/upload'));
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  var detailData = {};

  Future getData() async {
    try {
      final assignedCourier = await SharedToken.univGetterString('username');
      final userId = await SharedToken.univGetterString('user_id');
      final orderCode =
          await SharedToken.univGetterString('selected_order_code');
      final response = await http.post(
        Uri.parse(
            '${kURL_ORIGIN}pengiriman/kurir/get-supir-task-detail?courier_id=$userId&order_code=$orderCode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            detailData = jsonDecode(response.body)['data'][0];
          });
        }
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  Position? _currentPosition;
  bool inRadiusToEndTask = false;

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      final destinationLat = double.parse(detailData['destination_lat']);
      final destinationLong = double.parse(detailData['destination_long']);

      bool isInRadiusCheck = isInRadius(_currentPosition!.latitude,
          _currentPosition!.longitude, destinationLat, destinationLong, 9500);

      if (mounted) {
        setState(() {
          inRadiusToEndTask = isInRadiusCheck;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the earth in meters
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c; // Distance in meters

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  bool isInRadius(double currentLat, double currentLon, double targetLat,
      double targetLon, double radiusInMeters) {
    double distance =
        calculateDistance(currentLat, currentLon, targetLat, targetLon);
    return distance <= radiusInMeters;
  }

  @override
  void initState() {
    super.initState();
    getData().then((value) => _getCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    return detailData.isEmpty
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detailData['status'].toString().toUpperCase(),
                      style: detailData['status'] == 'pending'
                          ? const TextStyle(
                              color: Colors.orange, fontWeight: FontWeight.bold)
                          : detailData['status'] == 'shipping'
                              ? const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)
                              : detailData['status'] == 'shipping'
                                  ? const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)
                                  : const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                    ),
                    const Text('Order Date')
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order NO : ${detailData['order_code']}',
                    ),
                    Text(detailData['delivery_date'])
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Weight',
                    ),
                    Text('${detailData['package_weight']} kg')
                  ],
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 0.5, // Adjust this value for the thickness
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pickup Address'),
                          Text(
                            detailData['pickup_address']
                                .toString()
                                .substring(0, 32),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          // Text('picked up from muh rafli'),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 0.5, // Adjust this value for the thickness
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Address'),
                          Text(
                            detailData['destination_address']
                                .toString()
                                .substring(0, 32),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: detailData['status'] == 'pending'
                          ? ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pushNamed(
                                    context, CourierScannerScreen.routeName);
                              },
                              icon: const Icon(Icons.camera_enhance),
                              label: const Text('Scan'))
                          : ElevatedButton.icon(
                              onPressed: _takePicture,
                              icon: Icon(Icons.attachment,
                                  color: Colors.green[800]),
                              label: Text(
                                'Finish Task (Add Attachment)',
                                style: TextStyle(color: Colors.green[800]),
                              )),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton.icon(
                          onPressed: () async {
                            final url =
                                'https://www.google.com/maps/dir/${_currentPosition!.latitude},${_currentPosition!.longitude}/${detailData['pickup_lat']},${detailData['pickup_long']}/${detailData['destination_lat']},${detailData['destination_long']}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Open Map')),
                    )
                  ],
                )
              ],
            ),
          );
  }
}
