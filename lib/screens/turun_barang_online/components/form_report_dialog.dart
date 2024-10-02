import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sima_pengiriman/constants.dart';

import '../../../shared_preferences/shared_token.dart';
import 'package:http/http.dart' as http;

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
  String dropdownValue = 'LAPORAN_KM';

  File? _selectedImg;

  Map<String, dynamic> _listImgs = {};
  Map<String, String> _listImgsNm = {};

  Future<void> uploadFiles() async {
    final username = await SharedToken.univGetterString('username');
    final plat_no = await SharedToken.univGetterString('no_plat');
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${kURL_ORIGIN}pengiriman/supir-upload-report?tipe=$dropdownValue&username=$username&km=${kmTextController.text}&liter=${literTextController.text}&plat_no=${plat_no}&keterangan=${keteranganTextController.text}&lat=${position.latitude}&long=${position.longitude}'));
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
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future _pickImgFromGallery() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img == null) return;
    setState(() {
      _selectedImg = File(img.path);
    });
  }

  Future _pickImgFromCamera() async {
    final img = await ImagePicker().pickImage(source: ImageSource.camera);

    if (img == null) return;
    setState(() {
      _selectedImg = File(img.path);
    });
  }

  var kmTextController = TextEditingController();
  var literTextController = TextEditingController();

  var keteranganTextController = TextEditingController();

  var btnDisabled = false;

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
          child: btnDisabled ? Text('Submitting...') : Text('Submit'),
          onPressed: () async {
            if (btnDisabled) {
              return;
            }
            setState(() {
              btnDisabled = true;
            });
            await uploadFiles();
            // await _BodyState().getData();
            Navigator.pop(context);
            // Handle form submission logic here
          },
        ),
      ],
    );
  }
}
