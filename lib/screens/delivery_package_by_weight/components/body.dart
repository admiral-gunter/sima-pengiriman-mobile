import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/screens/map_picker/map_picker.dart';

import '../../../shared_preferences/shared_token.dart';
import '../../delivery_instant/components/dropdown_supir.dart';
import '../../looking_for_courier/looking_for_courier.dart';
import '../../delivery_instant/controllers/delivery_form_controller.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int tariff = 0;
  File? _selectedImg;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future _pickImgFromGallery() async {
    final returnedImg =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImg == null) return;
    setState(() {
      _selectedImg = File(returnedImg.path);
    });
  }

  double calculateDistance(
      double lat1, double long1, double lat2, double long2) {
    var dLat = _toRadians(lat2 - lat1);
    var dLong = _toRadians(long2 - long1);
    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);

    var a =
        pow(sin(dLat / 2), 2) + pow(sin(dLong / 2), 2) * cos(lat1) * cos(lat2);
    var c = 2 * asin(sqrt(a));
    const radius = 6371; // Radius of the Earth in kilometers
    final res = radius * c;
    return radius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  Future<void> _postData(BuildContext context) async {
    try {
      final DeliveryFormController ctl = Get.put(DeliveryFormController());

      if (ctl.form['package_weight'] == null ||
          ctl.form['receiver_telp'] == null ||
          ctl.form['receiver_name'] == null ||
          ctl.form['destination_address'] == null ||
          ctl.form['pickup_address'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all the possible fields',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      var closestLocationDriver = null;

      ctl.form['delivery_type'] = 'PACKAGE_BY_WEIGHT';
      ctl.form['delivery_date'] = '$selectedDate $selectedTime';
      ctl.form['pricing'] = tariff;
      ctl.form['user_id'] = await SharedToken.univGetterString('user_id');
      ctl.form['user_name'] = await SharedToken.univGetterString('username');
      final token = await SharedToken.tokenGetter();
      final Uri url =
          Uri.parse('${kURL_ORIGIN}pengiriman/kurir/create-order?token=$token');
      var request = http.MultipartRequest('POST', url);

      if (_selectedImg != null) {
        var stream = http.ByteStream(_selectedImg!.openRead().cast());
        var length = await _selectedImg!.length();
        var multipartFile = http.MultipartFile(
          'file',
          stream,
          length,
          filename: _selectedImg!.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      request.fields['dataset'] = jsonEncode(ctl.form);
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        await SharedToken.univSetterString(
            'generated_order_code', jsonDecode(responseBody)['data']);
        Navigator.pushNamed(context, LookingForCourier.routeName);
      } else {
        print('Request failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request failed with status: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error in sending data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in sending data: $e'),
        ),
      );
    }
  }

  var eval = null;
  var paramEval = null;

  Future<http.Response> getDeliveryType() async {
    _itemSize.length = 0;
    String url =
        '${kURL_ORIGIN}pengiriman/kurir/get-delivery-type?service_delivery_name=PACKAGE_BY_WEIGHT';
    // Define the headers
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
    );

    // Handle the response
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      paramEval = resp['data']['eval'];
      eval = resp['data']['eval_param'].toString().split(',');

      final detType = resp['data']['det_type'].toString().split(',');
      final detCalc = resp['data']['det_calc'].toString().split(',');

      for (var i = 0; i < detType.length; i++) {
        if (i == 0) {
          setState(() {
            if (mounted) {
              _selectedValue = '${detType[i]}-${int.parse(detCalc[i])}';
            }
          });
        }

        setState(() {
          if (mounted) {
            _itemSize.add({
              "text": '${detType[i]} - ${detCalc[i]}K',
              "value": '${detType[i]}-${int.parse(detCalc[i])}'
            });
          }
        });
      }

      // The request was successful
    } else {
      // The request failed
      print('Failed to send POST request: ${response.statusCode}');
    }

    return response;
  }

  final TextEditingController weightController = TextEditingController();
  final TextEditingController pckgDetailController = TextEditingController();
  final TextEditingController receiverNmController = TextEditingController();
  final TextEditingController receiverNoTlpController = TextEditingController();
  final TextEditingController qtyPkgweightController = TextEditingController();

  @override
  void initState() {
    getDeliveryType();
    final DeliveryFormController ctl = Get.put(DeliveryFormController());
    ctl.form['delivery_type'] = 'PACKAGE_BY_WEIGHT';

    super.initState();
    if (ctl.form['package_weight'] != null) {
      weightController.text = ctl.form['package_weight'];
    }

    if (ctl.form['package_detail'] != null) {
      pckgDetailController.text = ctl.form['package_detail'];
    }

    if (ctl.form['receiver_name'] != null) {
      receiverNmController.text = ctl.form['receiver_name'];
    }

    if (ctl.form['receiver_telp'] != null) {
      receiverNoTlpController.text = ctl.form['receiver_telp'];
    }

    if (ctl.form['quantity'] != null) {
      qtyPkgweightController.text = ctl.form['quantity'].toString();
    } else {
      qtyPkgweightController.text = '0';
      ctl.form['quantity'] = 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    weightController.dispose();
    pckgDetailController.dispose();
    receiverNmController.dispose();
    receiverNoTlpController.dispose();
    qtyPkgweightController.dispose();
  }

  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  var _selectedValue;
  final List<Map<String, dynamic>> _itemSize = [];
  @override
  Widget build(BuildContext context) {
    final DeliveryFormController ctl = Get.put(DeliveryFormController());
    return SizedBox(
      height:
          WidgetsBinding.instance.window.viewInsets.bottom > 0.0 ? 500 : 800,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                InkWell(
                  onTap: () async {
                    await SharedToken.univSetterString(
                        'type_pickup', 'pickup_location');
                    Navigator.pushReplacementNamed(
                        context, MapPicker.routeName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pick-up Location',
                              style: TextStyle(fontSize: 10)),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 50,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Obx(
                                () => Text(
                                    ctl.form['pickup_address'] ?? 'Adress..'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    await SharedToken.univSetterString(
                        'type_pickup', 'pickup_destination');
                    Navigator.pushReplacementNamed(
                        context, MapPicker.routeName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pick-up Destination',
                              style: TextStyle(fontSize: 10)),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 50,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Obx(() => Text(
                                  ctl.form['destination_address'] ??
                                      'Adress...')),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Date & Time Pickup')),
                Row(
                  children: <Widget>[
                    FilledButton(
                      onPressed: () => _selectDate(context),
                      child:
                          Text(' ${selectedDate.toString().substring(0, 10)}'),
                    ),
                    SizedBox(width: 10),
                    FilledButton(
                      onPressed: () => _selectTime(context),
                      child:
                          Text(' ${selectedTime.toString().substring(10, 15)}'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Input package weight',
                    labelText: 'Weight (kg)',
                  ),
                  onChanged: (value) {
                    ctl.form['package_weight'] = value;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ExpansionTile(
                  title: Text('Weights (Kg)'),
                  initiallyExpanded: _isExpanded,
                  onExpansionChanged: (expanded) {
                    if (!expanded) {
                      _toggleExpanded(); // Collapse when expanded state changes to false
                    }
                  },
                  children: [
                    ListTile(
                      title: Text('20Kg'),
                      onTap: () {
                        ctl.form['package_weight'] = 20;
                        setState(() {
                          weightController.text = '20';
                        });
                        _toggleExpanded();
                        // Handle item 1 click
                      },
                    ),
                    ListTile(
                      title: Text('30kg'),
                      onTap: () {
                        ctl.form['package_weight'] = 30;
                        setState(() {
                          weightController.text = '30';
                        });
                        _toggleExpanded();
                        // Handle item 2 click
                      },
                    ),
                    ListTile(
                      title: Text('50kg'),
                      onTap: () {
                        ctl.form['package_weight'] = 50;
                        setState(() {
                          weightController.text = '50';
                        });
                        _toggleExpanded();
                        // Handle item 2 click
                      },
                    ),
                    ListTile(
                      title: Text('80kg'),
                      onTap: () {
                        ctl.form['package_weight'] = 80;
                        setState(() {
                          weightController.text = '80';
                        });
                        _toggleExpanded();
                        // Handle item 2 click
                      },
                    ),
                    ListTile(
                      title: Text('100kg'),
                      onTap: () {
                        setState(() {
                          weightController.text = '100';
                        });
                        ctl.form['package_weight'] = 100;

                        _toggleExpanded();
                        // Handle item 2 click
                      },
                    ),
                    // Add more ListTiles as needed
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: qtyPkgweightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Input package quantity',
                    labelText: 'Qty',
                  ),
                  onChanged: (value) {
                    ctl.form['quantity'] = value;
                    final price =
                        int.parse(_selectedValue.toString().split('-')[1]);
                    final totalPrice = price * int.parse(ctl.form['quantity']);
                    setState(() {
                      tariff = totalPrice;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.topLeft, child: Text('Pilih Ukuran')),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: double.infinity,
                  child: DropdownButton<String>(
                    hint: Text('Pilih Ukuran'),
                    value: _selectedValue ?? null,
                    onChanged: (newValue) {
                      final price =
                          int.parse(newValue.toString().split('-')[1]);
                      final totalPrice =
                          price * int.parse(ctl.form['quantity']);
                      setState(() {
                        tariff = totalPrice;
                        _selectedValue = newValue!;
                      });
                    },
                    items: _itemSize.map<DropdownMenuItem<String>>(
                        (Map<String, dynamic> item) {
                      return DropdownMenuItem<String>(
                        value: item['value'],
                        child: Text(item['text']),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 100,
                  child: TextFormField(
                    controller: pckgDetailController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'Enter package details',
                      labelText: 'Package Details',
                    ),
                    onChanged: (value) {
                      ctl.form['package_detail'] = value;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: receiverNmController,
                  decoration: InputDecoration(
                    hintText: 'Penerima',
                    labelText: 'nama penerima',
                  ),
                  onChanged: (value) {
                    ctl.form['receiver_name'] = value;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: receiverNoTlpController,
                  scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 5 * 4),
                  decoration: InputDecoration(
                    hintText: 'No. Telp',
                    labelText: 'nomor telepon',
                  ),
                  onChanged: (value) {
                    ctl.form['receiver_telp'] = value;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(width: double.infinity, child: DropdownSupir()),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        await _pickImgFromGallery();
                      },
                      icon: Icon(Icons.camera),
                      label: Text('Foto Package (optional)')),
                )
              ]),
              _selectedImg != null
                  ? SizedBox(height: 150, child: Image.file(_selectedImg!))
                  : const Text('no image has been attached'),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                child: Row(
                  children: [
                    Text('Total Bil :'),
                    SizedBox(width: 5),
                    Text(NumberFormat.currency(locale: 'id', symbol: 'Rp')
                        .format(tariff))
                  ],
                ),
              ),
              const SizedBox(height: 70),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _postData(context);
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
