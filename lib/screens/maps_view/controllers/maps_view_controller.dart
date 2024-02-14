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
  var liveLokRefData = {
    "lat_cur": '',
    "lat_dest": -6.9299906,
    "lat_source": -6.9353,
    "long_cur": '',
    "long_dest": 107.5689666,
    "long_source": 107.7169,
  }.obs;
}
