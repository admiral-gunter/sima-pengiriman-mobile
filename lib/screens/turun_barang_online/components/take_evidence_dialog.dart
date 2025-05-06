import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:sima_pengiriman/components/loading_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';
import '../../../helper/database_helper.dart';
import '../../../shared_preferences/shared_token.dart';
import '../../menu_select_customer/controllers/menu_select_customer_controller.dart';
import '../controllers/turun_barang_online_controller.dart';
import 'package:http/http.dart' as http;

void _showTakeEvidncDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return TakeEvidenceDialog();
    },
  );
}

class TakeEvidenceDialog extends StatefulWidget {
  @override
  _TakeEvidenceDialogState createState() => _TakeEvidenceDialogState();
}

class _TakeEvidenceDialogState extends State<TakeEvidenceDialog> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  List<String> _imageNames = [];
  List<String> _imagePaths = [];
  TextEditingController _keteranganTxt = TextEditingController();
  bool _evidenceTaken = false;

  Future<void> _pickImgFromGallery() async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked == null || picked.isEmpty) return;

    setState(() {
      _images = picked;
      _imageNames = picked.map((img) => img.name).toList();
      _imagePaths = picked.map((img) => img.path).toList();
    });
  }

  Future<void> _pickImgFromCamera() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.camera);
    if (img == null) return;

    setState(() {
      _images.add(img);
      _imageNames.add(img.name);
      _imagePaths.add(img.path);
    });
  }

  Future<void> _uploadFile(BuildContext context) async {
    if (_images.isEmpty) return;

    try {
      final uname = await SharedToken.univGetterString('username');
      final platNo = await SharedToken.univGetterString('no_plat');
      final locData = await Location().getLocation();

      final ctk = Get.put(MenuSelectCustomerController());
      final ctl = Get.put(TurunBarangOnlineController());

      if (!ctk.internetConnected.value) {
        for (var path in _imagePaths) {
          final insertData = {
            'file': path,
            'nomor_order': ctl.noSuratJalanSelected.value,
            'username': uname,
            'keterangan': _keteranganTxt.text,
            'plat_no': platNo,
            'latitude': locData.latitude.toString(),
            'longitude': locData.longitude.toString(),
          };
          await DatabaseHelper.instance
              .insertSupirUploadAttachmentTask(insertData);
        }
        return;
      }

      for (var img in _images) {
        final uri = Uri.parse(
          '${kURL_ORIGIN}pengiriman/supir-upload-attachment-task'
          '?nomor_order=${ctl.noSuratJalanSelected.value}'
          '&username=$uname'
          '&keterangan=${_keteranganTxt.text}'
          '&plat_no=$platNo'
          '&lat=${locData.latitude}'
          '&long=${locData.longitude}',
        );

        final request = http.MultipartRequest('POST', uri);
        final fileBytes = await File(img.path).readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: img.name,
        );
        request.files.add(multipartFile);

        final response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Uploaded ${img.name} successfully!')),
          );
          getAttachment();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Upload of ${img.name} failed: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ERROR: $e')),
      );
    }
  }

  Future getAttachment() async {
    try {
      final MenuSelectCustomerController ctk =
          Get.put(MenuSelectCustomerController());

      if (!ctk.internetConnected.value) {
        return;
      }
      final TurunBarangOnlineController ctl =
          Get.put(TurunBarangOnlineController());
      var url = Uri.parse(
          '${kURL_ORIGIN}pengiriman/get-supir-upload-attachment-task?nomor_order=${ctl.noSuratJalanSelected.value}');

      // Make the POST request
      http.Response response = await http.post(url);

      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the JSON
        var responseBody = json.decode(response.body)['data'];

        setState(() {
          attachments = responseBody;
        });
        print('Response body: $responseBody');
      } else {
        // If the server returns an error response, throw an exception
        print('Failed to load post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ERROR: ${e}')),
      );
    }
  }

  void _openFullScreen(BuildContext context, XFile img) {
    // Implement full-screen view if needed
  }

  var attachments = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAttachment();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bukti Turun Barang'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Foto terupload:'),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var item in attachments)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () async {
                            final Uri url = Uri.parse(
                                '${HOST}/uploads/image/${item['file_name']}');
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.network(
                                '${HOST}/uploads/image/${item['file_name']}',
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.white,
                                    child: const Center(
                                      child: Text(
                                        'Not Found',
                                        style: TextStyle(color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Foto terpilih'),
            SizedBox(
              height: 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _images.map((img) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: InkWell(
                        onTap: () => _openFullScreen(context, img),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(img.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text(
                                  'Load\nError',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _evidenceTaken = true;
                    });
                    await _pickImgFromGallery();
                  },
                  child: const Text('Galeri'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _evidenceTaken = true;
                    });
                    await _pickImgFromCamera();
                  },
                  child: const Text('Kamera'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _keteranganTxt,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        LoadingButton(
          label: 'Submit',
          onPressed: () async {
            if (_keteranganTxt.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('KETERANGAN WAJIB DI ISI!'),
                  action: SnackBarAction(label: 'Close', onPressed: () {}),
                ),
              );
              return;
            }
            await _uploadFile(context);
            if (!mounted) return;
            Navigator.of(context).pop();
          },
        )
        // TextButton(
        //   child: const Text('Submit'),
        //   onPressed: () async {
        //     if (_keteranganTxt.text.isEmpty) {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(
        //           content: Text('KETERANGAN WAJIB DI ISI!'),
        //           action: SnackBarAction(label: 'Close', onPressed: () {}),
        //         ),
        //       );
        //       return;
        //     }
        //     await _uploadFile(context);
        //     if (!mounted) return;
        //     Navigator.of(context).pop();
        //   },
        // ),
      ],
    );
  }
}
