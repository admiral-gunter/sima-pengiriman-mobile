import 'package:get/get.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';

import '../../../shared_preferences/shared_token.dart';

class ScannerOfflineController extends GetxController {
  RxMap snIdentifier = {}.obs;

  RxMap credentialBasic = {}.obs;

  RxList dataTap = [].obs;

  void updateSnIdentifier(String key, dynamic value) {
    snIdentifier[key] = value;
  }

  void updateCredentialBasic(String key, dynamic value) {
    credentialBasic[key] = value;
  }

  Future<Map<String, dynamic>> insertDataOffline() async {
    var noOG =
        'OGOF-SM-${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    Map<String, dynamic> data = {
      'sn': snIdentifier['sn'],
      'identifier': snIdentifier['identifier'],
      'location_id': credentialBasic['location'],
      'customer_id': credentialBasic['customer'],
      'lso': credentialBasic['lso'],
      'creator': await SharedToken.univGetterString('username'),
      'code': noOG
    };
    dataTap.add(data);
    Map<String, dynamic> inserted =
        await DatabaseHelper.instance.insertInventoryValidasiHistory(data);
    print(inserted);
    // snIdentifier.clear();
    // credentialBasic.clear();

    return inserted;
  }
}
