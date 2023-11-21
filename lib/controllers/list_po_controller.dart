import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ListPoController extends GetxController {
  RxList<dynamic> listBt = <dynamic>[].obs;
  RxInt page = 0.obs;
  RxInt start = 0.obs;
  RxString search = ''.obs;

  @override
  void onReady() {
    super.onReady();
    print('Widget ready for interaction');
  }

  Future getListBt() async {
    try {
      final token = await SharedToken.tokenGetter();
      final companyId = await SharedToken.companyGetter();
      final lokasi = await SharedToken.univGetterString('lokasi');
      // debugPrint('${token}, ${companyId}, ');
      var param =
          '?draw=${page.value}&columns[0][data]=&columns[0][name]=&columns[0][searchable]=true&columns[0][orderable]=false&columns[0][search][value]=&columns[0][search][regex]=false&columns[1][data]=0&columns[1][name]=&columns[1][searchable]=true&columns[1][orderable]=false&columns[1][search][value]=&columns[1][search][regex]=false&columns[2][data]=14&columns[2][name]=&columns[2][searchable]=true&columns[2][orderable]=false&columns[2][search][value]=&columns[2][search][regex]=false&columns[3][data]=&columns[3][name]=&columns[3][searchable]=true&columns[3][orderable]=false&columns[3][search][value]=&columns[3][search][regex]=false&columns[4][data]=&columns[4][name]=&columns[4][searchable]=true&columns[4][orderable]=false&columns[4][search][value]=&columns[4][search][regex]=false&columns[5][data]=2&columns[5][name]=&columns[5][searchable]=true&columns[5][orderable]=false&columns[5][search][value]=&columns[5][search][regex]=false&columns[6][data]=15&columns[6][name]=&columns[6][searchable]=true&columns[6][orderable]=false&columns[6][search][value]=&columns[6][search][regex]=false&columns[7][data]=6&columns[7][name]=&columns[7][searchable]=true&columns[7][orderable]=false&columns[7][search][value]=&columns[7][search][regex]=false&columns[8][data]=8&columns[8][name]=&columns[8][searchable]=true&columns[8][orderable]=false&columns[8][search][value]=&columns[8][search][regex]=false&columns[9][data]=&columns[9][name]=&columns[9][searchable]=true&columns[9][orderable]=false&columns[9][search][value]=&columns[9][search][regex]=false&start=${start}&length=10&search[value]=${search}&search[regex]=false';
      var url = Uri.parse(kURL_ORIGIN +
          'purchase-order/get-open/' +
          companyId +
          '/' +
          token! +
          param +
          '&location_id=${lokasi}');

      var response = await http.post(url);

      var res = jsonDecode(response.body);
      listBt.clear();

      // debugPrint('${res['data']}');
      listBt.addAll(res['data']);
      for (var i = 0; i < listBt.length; i++) {
        // listBt[i][6] = '0';
        listBt[i].add(0);
        // print(listBt[i].add);
      }
      update();
    } catch (e) {
      // await SharedToken.tokenRemover();

      // return 'TOKEN_EMPTY';
      return 'Error sending POST request: $e LOGOUT AND RECONNECT TO INTERNET CONNECTION';
      print('Error sending POST request: $e');
    }
  }

  Future chgPage(String prop) async {
    if (prop == 'prev') {
      start.value = start.value - 10;
      page.value = page.value - 1;
    } else if (prop == 'next') {
      start.value = start.value + 10;
      page.value = page.value + 1;
    }

    await getListBt();
  }

  Future scrollPage() async {
    start.value = start.value + 10;
    page.value = page.value + 1;

    await getListBtScroll();
  }

  Future getListBtScroll() async {
    try {
      final token = await SharedToken.tokenGetter();
      final companyId = await SharedToken.companyGetter();
      final lokasi = await SharedToken.univGetterString('lokasi');
      // listBt.clear();
      // debugPrint('${token}, ${companyId}, ');
      var param =
          '?draw=${page.value}&columns[0][data]=&columns[0][name]=&columns[0][searchable]=true&columns[0][orderable]=false&columns[0][search][value]=&columns[0][search][regex]=false&columns[1][data]=0&columns[1][name]=&columns[1][searchable]=true&columns[1][orderable]=false&columns[1][search][value]=&columns[1][search][regex]=false&columns[2][data]=14&columns[2][name]=&columns[2][searchable]=true&columns[2][orderable]=false&columns[2][search][value]=&columns[2][search][regex]=false&columns[3][data]=&columns[3][name]=&columns[3][searchable]=true&columns[3][orderable]=false&columns[3][search][value]=&columns[3][search][regex]=false&columns[4][data]=&columns[4][name]=&columns[4][searchable]=true&columns[4][orderable]=false&columns[4][search][value]=&columns[4][search][regex]=false&columns[5][data]=2&columns[5][name]=&columns[5][searchable]=true&columns[5][orderable]=false&columns[5][search][value]=&columns[5][search][regex]=false&columns[6][data]=15&columns[6][name]=&columns[6][searchable]=true&columns[6][orderable]=false&columns[6][search][value]=&columns[6][search][regex]=false&columns[7][data]=6&columns[7][name]=&columns[7][searchable]=true&columns[7][orderable]=false&columns[7][search][value]=&columns[7][search][regex]=false&columns[8][data]=8&columns[8][name]=&columns[8][searchable]=true&columns[8][orderable]=false&columns[8][search][value]=&columns[8][search][regex]=false&columns[9][data]=&columns[9][name]=&columns[9][searchable]=true&columns[9][orderable]=false&columns[9][search][value]=&columns[9][search][regex]=false&start=${start}&length=10&search[value]=${search}&search[regex]=false';
      var url = Uri.parse(kURL_ORIGIN +
          'purchase-order/get-open/' +
          companyId +
          '/' +
          token! +
          param +
          '&location_id=${lokasi}');

      var response = await http.post(url);

      var res = jsonDecode(response.body);

      // debugPrint('${res['data']}');
      listBt.addAll(res['data']);
      for (var i = 0; i < listBt.length; i++) {
        // listBt[i][6] = '0';
        listBt[i].add(0);
        // print(listBt[i].add);
      }
      update();
    } catch (e) {
      await SharedToken.tokenRemover();

      return 'TOKEN_EMPTY';
      print('Error sending POST request: $e');
    }
  }

  Future searchByTxt(String prop) async {
    search.value = prop;
    await getListBt();
  }
}
