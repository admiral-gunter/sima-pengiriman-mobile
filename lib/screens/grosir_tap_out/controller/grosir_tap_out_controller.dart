import 'package:get/get.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';

import '../../../shared_preferences/shared_token.dart';
import '../../scanner_offline/controller/scanner_offline_controller.dart';

class GrosirTapOutController extends GetxController {
  RxMap snIdentifier = {}.obs;

  RxMap credentialBasic = {}.obs;

  // RxList dataTap = [].obs;

  void updateSnIdentifier(String key, dynamic value) {
    snIdentifier[key] = value;
  }

  void updateCredentialBasic(String key, dynamic value) {
    credentialBasic[key] = value;
  }

  Future insertDataOffline() async {
    var noOG =
        'OGOF-SM-${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}}}';
    Map<String, dynamic> data = {
      'sn': snIdentifier['sn'],
      'identifier': snIdentifier['identifier'],
      'location_id': credentialBasic['location'],
      'customer_id': credentialBasic['customer'],
      'creator': await SharedToken.univGetterString('username'),
      'code': noOG
    };
    // dataTap.add(data);
    // Map<String, dynamic> inserted =
    //     await DatabaseHelper.instance.insertInventoryValidasiHistory(data);
    // print(inserted);
    snIdentifier.clear();
    credentialBasic.clear();

    // return inserted;
  }

  Future<dynamic> insertDataOfflineTap(
      dynamic dataTap, dynamic customer) async {
    try {
      var noOG =
          'GRS-OFF-${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      // Map<String, dynamic> data = {
      //   'sn': snIdentifier['sn'],
      //   'identifier': snIdentifier['identifier'],
      //   'location_id': credentialBasic['location'],
      //   'customer_id': credentialBasic['customer'],
      //   'creator': await SharedToken.univGetterString('username'),
      //   'code': noOG
      // };
      final userLokasi = await SharedToken.univGetterString('lokasi');

      Map<String, dynamic> e = {'result': false, 'message': '.'};
      for (var i = 0; i < dataTap.length; i++) {
        Map<String, dynamic> data = {
          'sn': dataTap[i]['sn'],
          'identifier': dataTap[i]['identifier'],
          // 'location_id': credentialBasic['location'],
          'location_id': userLokasi,
          'customer_id': customer,
          'creator': await SharedToken.univGetterString('username'),
          'code': noOG,
        };
        // final dataInsert = dataTap[i];
        e = await DatabaseHelper.instance.insertGrosirTapOut(data);
        print(e);
        if (!e['result']) {
          return e;
        }
      }

      return e;
    } catch (e) {
      return e;
    }
  }
}
