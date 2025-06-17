import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import '../../../constants.dart';
import '../../menu_select_customer/controllers/menu_select_customer_controller.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List supirReport = [];

  @override
  void initState() {
    getData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cekStatusAbsen();
    });
    _checkLocationPermission();
    super.initState();
  }

  Future cekStatusAbsen() async {
    final stsAbsen = await SharedToken.univGetterString('STS_ABSEN');

    if (stsAbsen == 'BELUM_ABSEN') {
      List? dbCheck =
          await DatabaseHelper.instance.getLastDailyReportSupirToday();

      if (dbCheck.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'BUAT LAPORAN KM UNTUK MELANJUTKAN TUGAS',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(days: 1),
            action: SnackBarAction(label: 'Ok', onPressed: () {}),
          ),
        );
      }
    }
  }

  Future getData() async {
    final creatdBy = await SharedToken.univGetterString('username');
    final url = Uri.parse(
        '${kURL_ORIGIN}pengiriman/get-supir-upload-report?created_by=${creatdBy}');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        setState(() {
          supirReport = jsonDecode(response.body)[0];
        });

        print('Response data: ${response.body}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
              content: Text(
                '${response.body}',
              )),
        );
        print('Request failed with status: ${response.statusCode}.');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  bool _isLoading = false;
  String _statusMessage = 'Checking permission...';

  // @override
  // void initState() {
  //   super.initState();
  //   _checkLocationPermission();
  // }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    setState(() {
      _isLoading = false;
      _statusMessage = (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse)
          ? 'Permission Granted'
          : 'Permission Denied';
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Location Permission Example'),
  //     ),
  //     body: Center(
  //       child: _isLoading
  //           ? CircularProgressIndicator()
  //           : Text(
  //               'Location Permission Status: $_statusMessage',
  //               style: TextStyle(fontSize: 18),
  //             ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. Cari... field
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Cari...',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            autocorrect: false,
          ),

          SizedBox(height: 12),

          // 2. “Tambah Laporan” button aligned to the right
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {
                formReportDialog(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // background color
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 14),
              ),
              child: Text(
                'Tambah Laporan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          SizedBox(height: 16),

          // 3. The list takes all remaining space
          Expanded(
            child: ListView.builder(
              itemCount: supirReport.length,
              itemBuilder: (context, index) {
                final report = supirReport[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('${report['tipe']}'),
                    subtitle: Text(
                      'KM: ${report['km']}   Liter: ${report['liter']}',
                      style: TextStyle(fontSize: 13),
                    ),
                    trailing: Text(
                      '${report['created_at']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void formReportDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return FormReportDialog();
    },
  );
}

class FormReportDialog extends StatefulWidget {
  @override
  _FormReportDialogState createState() => _FormReportDialogState();
}

class _FormReportDialogState extends State<FormReportDialog> {
  String dropdownValue = '-';
  bool btnDisabled = false;

  // Instead of three separate maps/keys, we keep a fixed-length List<File?> of size 3.
  //  index 0: foto_struck
  //  index 1: indikator_bensin
  //  index 2: km_kendaraan
  List<File?> images = List<File?>.filled(3, null);
  List<String> imageNames = List<String>.filled(3, '');

  // Error messages
  String errMsgStruk = '';
  String errMsgIndikator = '';
  String errMsgKmKendaraan = '';
  String errMsgTipeLaporan = '';
  String errMsgTextKm = '';
  String errMsgTextLiter = '';

  final kmTextController = TextEditingController();
  final literTextController = TextEditingController();
  final keteranganTextController = TextEditingController();

  Future<void> _pickMultipleImages() async {
    // Allow picking up to 3 images. The user can choose fewer, but we will map them by index.
    final pickedFiles = await ImagePicker().pickMultiImage(
      imageQuality: 80,
    );
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    // Reset before assigning
    setState(() {
      for (int i = 0; i < 3; i++) {
        images[i] = null;
        imageNames[i] = '';
      }
      // Assign up to the first 3 picked images
      for (int i = 0; i < pickedFiles.length && i < 3; i++) {
        images[i] = File(pickedFiles[i].path);
        imageNames[i] = File(pickedFiles[i].path)
            .uri
            .pathSegments
            .last; // just the filename
      }
      // If fewer than 3 picked, any leftover entries stay null/empty.
    });
  }

  Future<void> uploadFiles() async {
    final username = await SharedToken.univGetterString('username');
    final platNo = await SharedToken.univGetterString('no_plat');
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final MenuSelectCustomerController ctl =
        Get.put(MenuSelectCustomerController());

    // If offline, insert into local DB per image
    if (!ctl.internetConnected.value) {
      for (int i = 0; i < 3; i++) {
        final filePath = images[i]?.path;
        if (filePath != null) {
          // Parse liter if needed; original code wasn’t actually using the parsed value.
          int liter = 0;
          if (literTextController.text.isNotEmpty) {
            liter = int.parse(literTextController.text);
          }
          final fieldName =
              ['foto_struck', 'indikator_bensin', 'km_kendaraan'][i];

          final resp = await DatabaseHelper.instance.insertDailyReportSupir(
            literTextController.text,
            kmTextController.text,
            dropdownValue,
            filePath,
            fieldName,
            keteranganTextController.text,
            username,
            platNo,
            position.latitude.toString(),
            position.longitude.toString(),
          );
          print(resp);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () {},
          ),
          content: Text('Laporan berhasil dicatat!'),
        ),
      );
      return;
    }

    // Online: prepare MultipartRequest
    final uri = Uri.parse(
      '${kURL_ORIGIN}pengiriman/supir-upload-report'
      '?tipe=$dropdownValue'
      '&username=$username'
      '&km=${kmTextController.text}'
      '&liter=${literTextController.text}'
      '&plat_no=$platNo'
      '&keterangan=${keteranganTextController.text}'
      '&lat=${position.latitude}'
      '&long=${position.longitude}',
    );
    final request = http.MultipartRequest('POST', uri);

    // Field names in order
    final fieldNames = ['foto_struck', 'indikator_bensin', 'km_kendaraan'];

    // Attach each non-null image
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldNames[i], file.path),
        );
      }
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      setState(() {
        btnDisabled = false;
      });

      if (response.statusCode == 200) {
        print('Files uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody)),
        );
      } else {
        print('File upload failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed: $responseBody')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Formulir Laporan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // KM input
            TextFormField(
              controller: kmTextController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'KM',
                hintText: 'Masukkan kilometer...',
              ),
            ),
            if (errMsgTextKm.isNotEmpty)
              Text(
                errMsgTextKm,
                style: TextStyle(fontSize: 10, color: Colors.red),
              ),
            SizedBox(height: 20),

            // Dropdown tipe laporan
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Pilih Tipe Laporan:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (errMsgTipeLaporan.isNotEmpty)
                  Text(
                    errMsgTipeLaporan,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        errMsgTipeLaporan = '';
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>['-', 'PENGISIAN_BBM', 'LAPORAN_KM']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),

                // If PENGISIAN_BBM: show field for liter
                if (dropdownValue == 'PENGISIAN_BBM') ...[
                  TextFormField(
                    controller: literTextController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Liter',
                      hintText: 'Masukkan Liter Pengisian Bensin',
                    ),
                  ),
                  if (errMsgTextLiter.isNotEmpty)
                    Text(
                      errMsgTextLiter,
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  SizedBox(height: 20),
                ],

                // Single button to pick up to 3 images at once
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unggah Foto KM mobil, spidometer, dan struk (max 3 foto)',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: _pickMultipleImages,
                      child: Text('Pilih Foto (max 3)'),
                    ),
                    SizedBox(height: 8),

                    // Show filenames and any individual errors
                    _buildImageInfoRow(
                      index: 0,
                      // label: 'Foto Struk',
                      fileName: imageNames[0],
                      errMsg: errMsgStruk,
                    ),
                    _buildImageInfoRow(
                      index: 1,
                      // label: 'Indikator BBM',
                      fileName: imageNames[1],
                      errMsg: errMsgIndikator,
                    ),
                    _buildImageInfoRow(
                      index: 2,
                      // label: 'KM Kendaraan',
                      fileName: imageNames[2],
                      errMsg: errMsgKmKendaraan,
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Keterangan field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keterangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: keteranganTextController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Isi Keterangan di sini',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      // Actions: Close & Submit
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: btnDisabled ? Text('Mohon Tunggu...') : Text('Submit'),
          onPressed: () async {
            if (btnDisabled) return;

            // Reset per-image errors
            setState(() {
              errMsgStruk = '';
              errMsgIndikator = '';
              errMsgKmKendaraan = '';
              errMsgTipeLaporan = '';
              errMsgTextKm = '';
              errMsgTextLiter = '';
            });

            // Validate tipe laporan
            if (dropdownValue == '-') {
              setState(() {
                errMsgTipeLaporan = 'HARAP PILIH TIPE LAPORAN!';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Harap pilih tipe laporan!')),
              );
              return;
            }

            // Always require KM
            if (kmTextController.text.isEmpty) {
              setState(() {
                errMsgTextKm = 'Harap isi KM!';
              });
              return;
            }

            // If PENGISIAN_BBM, require liter and struk
            if (dropdownValue == 'PENGISIAN_BBM') {
              if (literTextController.text.isEmpty) {
                setState(() {
                  errMsgTextLiter = 'Harap isi Liter!';
                });
                return;
              }
              if (images[0] == null) {
                setState(() {
                  errMsgStruk = 'Harap unggah foto struk!';
                });
                return;
              }
            }

            // For either LAPORAN_KM or PENGISIAN_BBM, require indikator and KM kendaraan
            if (dropdownValue == 'LAPORAN_KM' ||
                dropdownValue == 'PENGISIAN_BBM') {
              if (images[1] == null) {
                setState(() {
                  errMsgIndikator = 'Harap unggah foto indikator!';
                });
              }
              if (images[2] == null) {
                setState(() {
                  errMsgKmKendaraan = 'Harap unggah foto KM kendaraan!';
                });
              }
              if (errMsgIndikator.isNotEmpty || errMsgKmKendaraan.isNotEmpty) {
                return;
              }
            }

            // If validation passes:
            setState(() {
              btnDisabled = true;
            });
            await uploadFiles();
            // Assuming you still want to call getData on body state:
            await _BodyState().getData();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  /// Helper to build a row showing a single image’s filename + error
  Widget _buildImageInfoRow({
    required int index,
    // required String label,
    required String fileName,
    required String errMsg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fileName.isNotEmpty)
          Text(
            fileName,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        if (errMsg.isNotEmpty)
          Text(
            errMsg,
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        SizedBox(height: 8),
      ],
    );
  }
}
