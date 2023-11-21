import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/constants.dart';

class SignInController {
  Map<String, String> loginCredential = {'username': '', 'password': ''};

  void chgCredential(String ky, String txt) {
    loginCredential[ky] = txt;
  }

  Future<dynamic> loging() async {
    // debugPrint('${loginCredential}');
    try {
      var url = Uri.parse(kURL_ORIGIN + 'login');

      var response = await http.post(url, body: loginCredential);

      return response.body;
    } catch (e) {
      print('Error sending POST request: $e');
    }
  }
}
