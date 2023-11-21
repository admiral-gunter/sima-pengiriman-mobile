import 'package:get/get.dart';

class ServiceOfflineController extends GetxController {
  RxMap basicCredential = {}.obs;

  void changeBasicCredential(String key, dynamic value) {
    basicCredential[key] = value;
  }
}
