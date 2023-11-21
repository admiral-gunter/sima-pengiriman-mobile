import 'package:get/get.dart';

class UniversalScannerData extends GetxController {
  RxMap snIdentifier = {}.obs;
  RxList itemScanned = [].obs;

  @override
  void onInit() {
    super.onInit();
    // Your initialization code here
    itemScanned.clear();
    snIdentifier.clear();
  }

  @override
  void onClose() {
    itemScanned.clear();
    snIdentifier.clear();
    // time to close some resources and to do other cleanings
  }

  void updateSnIdentifier(String key, dynamic value) {
    snIdentifier[key] = value;
  }

  void addItemScan() {
    itemScanned.add(Map.from(snIdentifier));
  }

  void clearSnIdentifier() {
    snIdentifier.clear();
  }
}
