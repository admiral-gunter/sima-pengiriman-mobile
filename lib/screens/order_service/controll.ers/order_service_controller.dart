import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart'; // For getting the file name
import 'package:mime/mime.dart'; // For getting the MIME type of a file
import 'package:http_parser/http_parser.dart';

class OrderServiceController extends GetxController {
  var listSnProduct = [].obs;

  RxInt productIdSelected = 0.obs;
  RxInt inventoryLocationIdSelected = 0.obs;
  RxInt saleWholesaleCustomerIdSelected = 0.obs;

  var saleWholesaleCustomerNamenAddress =
      {'address': '', 'customer_name': ''}.obs;

  RxBool uploadsukses = false.obs;

  Future<void> uploadImagesAndFormData(
      List<File> images, Map<String, String> formData, String uploadUrl) async {
    var uri = Uri.parse(uploadUrl);

    var request = http.MultipartRequest('POST', uri);

    // Add form fields
    formData.forEach((key, value) {
      request.fields[key] = value;
    });

    request.fields['customer_address'] =
        saleWholesaleCustomerNamenAddress['address']!;

    request.fields['customer_name'] =
        saleWholesaleCustomerNamenAddress['customer_name']!;

    request.fields['customer_id'] =
        saleWholesaleCustomerIdSelected.value.toString();
    // Add image files
    int index = 0;
    for (var image in images) {
      // var mimeType = lookupMimeType(image.path);
      // var imageName = basename(image.path);
      request.files.add(await http.MultipartFile.fromPath(
          'images[]', // Field name for the image (change as needed)
          image.path
          // contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
      index++;
    }

    try {
      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        uploadsukses.value = true;
        print('Upload successful');
        print(responseBody);
      } else {
        uploadsukses.value = false;

        print('Upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      uploadsukses.value = false;

      print('Error during upload: $e');
    }
  }
}
