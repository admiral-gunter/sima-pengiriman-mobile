import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/constants.dart';

class SignInController {
  String kURL_ORIGIN2 = kURL_ORIGIN;
  Map<String, String> loginCredential = {'username': '', 'password': ''};

  void chgCredential(String ky, String txt) {
    loginCredential[ky] = txt;
  }

  Future<dynamic> loging() async {
    try {
      final timeoutDuration = Duration(seconds: 20);
      var url = Uri.parse('${kURL_ORIGIN2}pengiriman/master-supir-login');
      var response = await http.post(url, body: loginCredential);

      return response.body;
      // } on TimeoutException catch (e) {
      //   return {'success': false, 'msg': 'Request timed out: $e'};
    } catch (e) {
      print('Error sending POST request: $e');
      return {'success': false, 'msg': 'Error sending POST request: $e'};
    }
  }
}
