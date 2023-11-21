import 'package:shared_preferences/shared_preferences.dart';

class SharedToken {
  static Future<String?> tokenGetter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future tokenSetter(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  static Future tokenRemover() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }

  static Future companySetter(String companyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('company_id', companyId);
  }

  static Future companyGetter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('company_id');
  }

  static Future univSetterString(String prop, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(prop, value);
  }

  static Future univGetterString(String prop) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(prop);
  }
}
