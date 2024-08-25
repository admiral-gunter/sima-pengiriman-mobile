import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

import '../../../constants.dart';
import '../../turun_barang_online/controllers/turun_barang_online_controller.dart';

class BarangTidakMuatController {
  Future makePostRequest(String inventoryId) async {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    final sj = ctl.noSuratJalanSelected.value.toString().replaceAll(' ', '');

    final username = await SharedToken.univGetterString('username');
    // URL endpoint
    final url = Uri.parse('${kURL_ORIGIN}supir-barang-tidak-muat');

    // Data yang ingin dikirimkan dalam request body
    final Map<String, dynamic> requestData = {
      'inventory_id': inventoryId,
      'username': username,
      'sj': sj
    };

    // Headers (optional)
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer your_token_here', // Jika perlu token
    };

    // Mengirim POST request
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );

      // Mengecek status code
      if (response.statusCode == 200) {
        // Request berhasil, proses data di sini
        print('Response data: ${response.body}');

        return jsonDecode(response.body);
      } else {
        // Request gagal
        return {'status': 'gagal', 'msg': 'ERROR  ${response.statusCode}'};
        //  array('status' => $status, 'response' => $response_data, 'msg' => $msg
      }
    } catch (e) {
      return {'status': 'gagal', 'msg': 'ERROR  ${e}'};
      // Menangani error jika ada
    }
  }
}
