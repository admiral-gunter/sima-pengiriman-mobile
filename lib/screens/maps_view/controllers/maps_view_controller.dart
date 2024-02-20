import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared_preferences/shared_token.dart';
import 'dart:math';

class MapsViewController extends GetxController {
  RxMap<String, dynamic> liveLokRefData = {
    "lat_cur": '',
    "lat_dest": 0.0,
    "lat_source": 0.0,
    "long_cur": '',
    "long_dest": 0.0,
    "long_source": 0.0,
  }.obs;

   void updateLiveLokRefData(dynamic newData) {
    liveLokRefData.addAll(newData);
    // liveLokRefData= newData
  }
}
