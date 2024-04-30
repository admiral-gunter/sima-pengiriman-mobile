import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sima_pengiriman/constants.dart';
import '../controllers/delivery_form_controller.dart';

class DropdownSupir extends StatefulWidget {
  const DropdownSupir({super.key});

  @override
  State<DropdownSupir> createState() => _DropdownSupirState();
}

class _DropdownSupirState extends State<DropdownSupir> {
  Future getCourier() async {
    final response = await http.post(
      Uri.parse('${kURL_ORIGIN}pengiriman/kurir/get-supir'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Success! Response: ${response.body}');
      // setState(() {
      //   _dropdownItems = jsonDecode(response.body)['data'];
      // });
      final data = jsonDecode(response.body)['data'];
      setState(() {
        for (var i = 0; i < data.length; i++) {
          _dropdownItems.add(DropdownMenuItem(
            child: Text(data[i]['name']),
            value: data[i]['value'],
          ));
        }
      });
    } else {
      print('Failed with status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCourier();
  }

  @override
  String? _selectedItem;

// List of items as an array of objects with a more descriptive structure
  List<DropdownMenuItem<String>> _dropdownItems = [];

  @override
  Widget build(BuildContext context) {
    final DeliveryFormController ctl = Get.put(DeliveryFormController());

    return DropdownButton<String>(
      value: _selectedItem,
      onChanged: (newValue) async {
        setState(() {
          final List<dynamic> selected = newValue.toString().split('-');
          ctl.form['courier_id'] = selected[0];
          ctl.form['assigned_courier'] = selected[1];
          _selectedItem = newValue;
        });
      },
      items: _dropdownItems,
      hint: Text('Pilih Supir'), // Placeholder text when no item is selected
    );
  }
}
