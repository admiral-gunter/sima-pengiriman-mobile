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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'BUAT LAPORAN KM UNTUK MELANJUTKAN TUGAS',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(days: 1),
        ),
      );
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
          SnackBar(content: Text('${response.body}')),
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
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            // padding: EdgeInsets.symmetric(horizontal: 1.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(hintText: 'Cari...'),
                  autocorrect: false,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          formReportDialog(context);
                        },
                        child: Text('Tambah'),
                      ),
                    ]),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 5,
          child: ListView.builder(
            itemCount: supirReport.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${supirReport[index]['tipe']}'),
                subtitle: Text(
                    'KM : ${supirReport[index]['km']},  Liter : ${supirReport[index]['liter']}'),
                trailing: Text('${supirReport[index]['created_at']}'),
              );
            },
          ),
        ),
        // Another component taking the remaining 25% of the height
      ],
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

  File? _selectedImg;

  Map<String, dynamic> _listImgs = {};
  Map<String, String> _listImgsNm = {};

  Future<void> uploadFiles() async {
    final username = await SharedToken.univGetterString('username');
    final platNo = await SharedToken.univGetterString('no_plat');
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final MenuSelectCustomerController ctl =
        Get.put(MenuSelectCustomerController());

    if (!ctl.internetConnected.value) {
      _listImgs.forEach((key, value) async {
        // print('$key: $value');
        int liter = 0;
        if (literTextController.text.isNotEmpty) {
          int.parse(literTextController.text);
        }
        final resp = await DatabaseHelper.instance.insertDailyReportSupir(
            literTextController.text,
            kmTextController.text,
            dropdownValue,
            value,
            key,
            keteranganTextController.text,
            username,
            platNo,
            position.latitude.toString(),
            position.longitude.toString());

        print(resp);
      });
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan berhasil dicatat!')),
      );
      return;
    }

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${kURL_ORIGIN}pengiriman/supir-upload-report?tipe=$dropdownValue&username=$username&km=${kmTextController.text}&liter=${literTextController.text}&plat_no=$platNo&keterangan=${keteranganTextController.text}&lat=${position.latitude}&long=${position.longitude}'));
    // for (var file in selectedFiles) {
    //   request.files.add(await http.MultipartFile.fromPath('files', file.path));
    // }
    if (_listImgs['foto_struck'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'foto_struck', _listImgs['foto_struck']));
    }

    if (_listImgs['indikator_bensin'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'indikator_bensin', _listImgs['indikator_bensin']));
    }
    if (_listImgs['km_kendaraan'] != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'km_kendaraan', _listImgs['km_kendaraan']));
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        btnDisabled = false;
      });
      if (response.statusCode == 200) {
        print('Files uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${responseBody}')),
        );
      } else {
        print('File upload failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed: ${responseBody}')),
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

  Future _pickImgFromGallery() async {
    final img = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // maxHeight: 480,
        // maxWidth: 640,
        imageQuality: 80);

    if (img == null) return;
    setState(() {
      _selectedImg = File(img.path);
    });
  }

  Future _pickImgFromCamera() async {
    final img = await ImagePicker().pickImage(
        source: ImageSource.camera,
        // maxHeight: 480,
        // maxWidth: 640,
        imageQuality: 80);

    if (img == null) return;

    // Compress the image
    // final compressedImage = await compressImage(File(img.path));

    setState(() {
      _selectedImg = File(img.path);
    });
  }

  var kmTextController = TextEditingController();
  var literTextController = TextEditingController();

  var keteranganTextController = TextEditingController();

  var btnDisabled = false;

  String errMsgIndikator = '';
  String errMsgKmKendaraan = '';
  String errMsgStruk = '';
  String errMsgTipeLaporan = '';
  String errMsgTextKm = '';
  String errMsgTextLiter = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Formulir Laporan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: kmTextController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'KM', hintText: 'Masukkan kilometer...'),
            ),
            Text(
              errMsgTextKm,
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Pilih Tipe Laporan:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  errMsgTipeLaporan,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 1),
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
                SizedBox(
                  height: 20,
                ),
                dropdownValue == 'PENGISIAN_BBM'
                    ? Column(
                        children: [
                          TextFormField(
                            controller: literTextController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: 'Liter',
                                hintText: 'Masukkan Liter Pengisian Bensin'),
                          ),
                          Text(
                            errMsgTextLiter,
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Foto Struck'),
                              Text(
                                '${_listImgsNm['foto_struck']}',
                                style: TextStyle(fontSize: 8.0),
                              ),
                              Text(
                                errMsgStruk,
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.red),
                              ),
                              Row(children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await _pickImgFromGallery();
                                    setState(() {
                                      _listImgsNm['foto_struck'] =
                                          File(_selectedImg!.path)
                                              .uri
                                              .pathSegments
                                              .last;
                                      _listImgs['foto_struck'] =
                                          _selectedImg!.path;
                                    });
                                  },
                                  child: Text('Galeri'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _pickImgFromCamera();
                                    setState(() {
                                      _listImgsNm['foto_struck'] =
                                          File(_selectedImg!.path)
                                              .uri
                                              .pathSegments
                                              .last;
                                      _listImgs['foto_struck'] =
                                          _selectedImg!.path;
                                    });
                                  },
                                  child: Text('Kamera'),
                                ),
                              ]),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Indikator Bensin'),
                              Text(
                                '${_listImgsNm['indikator_bensin']}',
                                style: TextStyle(fontSize: 8.0),
                              ),
                              Text(
                                errMsgIndikator,
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.red),
                              ),
                              Row(children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await _pickImgFromGallery();
                                    setState(() {
                                      _listImgsNm['indikator_bensin'] =
                                          File(_selectedImg!.path)
                                              .uri
                                              .pathSegments
                                              .last;
                                      _listImgs['indikator_bensin'] =
                                          _selectedImg!.path;
                                    });
                                  },
                                  child: Text('Galeri'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _pickImgFromCamera();
                                    setState(() {
                                      _listImgsNm['indikator_bensin'] =
                                          File(_selectedImg!.path)
                                              .uri
                                              .pathSegments
                                              .last;
                                      _listImgs['indikator_bensin'] =
                                          _selectedImg!.path;
                                    });
                                  },
                                  child: Text('Kamera'),
                                ),
                              ]),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KM Kendaraan'),
                              Text(
                                '${_listImgsNm['km_kendaraan']}',
                                style: TextStyle(fontSize: 8.0),
                              ),
                              Text(
                                errMsgKmKendaraan,
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.red),
                              ),
                              Row(children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    setState(() {});
                                    await _pickImgFromGallery();
                                    setState(() {
                                      _listImgsNm['km_kendaraan'] =
                                          File(_selectedImg!.path)
                                              .uri
                                              .pathSegments
                                              .last;
                                      _listImgs['km_kendaraan'] =
                                          _selectedImg!.path;
                                    });
                                  },
                                  child: Text('Galeri'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _pickImgFromCamera();
                                    setState(() {
                                      _listImgsNm['km_kendaraan'] =
                                          File(_selectedImg!.path)
                                              .uri
                                              .pathSegments
                                              .last;
                                      _listImgs['km_kendaraan'] =
                                          _selectedImg!.path;
                                    });
                                  },
                                  child: Text('Kamera'),
                                ),
                              ]),
                            ],
                          ),
                        ],
                      )
                    : dropdownValue == 'LAPORAN_KM'
                        ? Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Indikator Bensin'),
                                  Text(
                                    '${_listImgsNm['indikator_bensin']}',
                                    style: TextStyle(fontSize: 8.0),
                                  ),
                                  Text(
                                    errMsgIndikator,
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.red),
                                  ),
                                  Row(children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {});
                                        await _pickImgFromGallery();
                                        setState(() {
                                          _listImgsNm['indikator_bensin'] =
                                              File(_selectedImg!.path)
                                                  .uri
                                                  .pathSegments
                                                  .last;
                                          _listImgs['indikator_bensin'] =
                                              _selectedImg!.path;
                                        });
                                      },
                                      child: Text('Galeri'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _pickImgFromCamera();
                                        setState(() {
                                          _listImgsNm['indikator_bensin'] =
                                              File(_selectedImg!.path)
                                                  .uri
                                                  .pathSegments
                                                  .last;
                                          _listImgs['indikator_bensin'] =
                                              _selectedImg!.path;
                                        });
                                      },
                                      child: Text('Kamera'),
                                    ),
                                  ]),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Foto KM Kendaraan'),
                                  Text(
                                    '${_listImgsNm['km_kendaraan']}',
                                    style: TextStyle(fontSize: 8.0),
                                  ),
                                  Text(
                                    errMsgKmKendaraan,
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.red),
                                  ),
                                  Row(children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {});
                                        await _pickImgFromGallery();
                                        setState(() {
                                          _listImgsNm['km_kendaraan'] =
                                              File(_selectedImg!.path)
                                                  .uri
                                                  .pathSegments
                                                  .last;
                                          _listImgs['km_kendaraan'] =
                                              _selectedImg!.path;
                                        });
                                      },
                                      child: Text('Galeri'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _pickImgFromCamera();
                                        setState(() {
                                          _listImgsNm['km_kendaraan'] =
                                              File(_selectedImg!.path)
                                                  .uri
                                                  .pathSegments
                                                  .last;
                                          _listImgs['km_kendaraan'] =
                                              _selectedImg!.path;
                                        });
                                      },
                                      child: Text('Kamera'),
                                    ),
                                  ]),
                                ],
                              ),
                            ],
                          )
                        : Text(''),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keterangan', // Label for the textarea
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            8), // Adds some space between the label and the input field
                    TextField(
                      controller: keteranganTextController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Isi Keterangan disini',
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
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: btnDisabled ? Text('Mohon Tunggu...') : Text('Submit'),
          onPressed: () async {
            if (btnDisabled) {
              return;
            }
            if (dropdownValue == '-') {
              setState(() {
                errMsgTipeLaporan = 'HARAP PILIH TIPE LAPORAN!';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Harap Pilih tipe laporan!')),
              );

              return;
            }

            setState(() {
              errMsgIndikator = '';
              errMsgKmKendaraan = '';
              errMsgStruk = '';
            });

            if (dropdownValue == 'LAPORAN_KM' ||
                dropdownValue == 'PENGISIAN_BBM') {
              if (kmTextController.text.isEmpty) {
                setState(() {
                  errMsgTextKm = 'Harap isi KM!';
                });
                return;
              }

              if (_listImgs['indikator_bensin'] == null) {
                setState(() {
                  errMsgIndikator = 'Harap isi foto indikator!';
                });
              }

              if (_listImgs['km_kendaraan'] == null) {
                setState(() {
                  errMsgKmKendaraan = 'Harap isi foto KM Kendaraan!';
                });
              }
            }

            if (dropdownValue == 'PENGISIAN_BBM') {
              if (literTextController.text.isEmpty) {
                setState(() {
                  errMsgTextLiter = 'Harap isi Liter!';
                });
                return;
              }
              if (_listImgs['foto_struck'] == null) {
                setState(() {
                  errMsgStruk = 'Harap isi foto struk!';
                });
                return;
              }
            }

            setState(() {
              btnDisabled = true;
            });
            await uploadFiles();
            await _BodyState().getData();
            Navigator.pop(context);
            // Handle form submission logic here
          },
        ),
      ],
    );
  }
}
