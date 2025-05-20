import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/maps_view/controllers/maps_view_controller.dart';
import 'package:sima_pengiriman/screens/menu/menu_screen.dart';
import 'package:sima_pengiriman/screens/menu_select_customer/menu_select_customer.dart';
import 'package:sima_pengiriman/screens/universal_scannner/universal_scanner_screen.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'package:location/location.dart';
import 'package:flutter_background/flutter_background.dart';
import '../barang_tidak_muat/barang_tidak_muat_screen.dart';
import '../menu_select_customer/controllers/menu_select_customer_controller.dart';
import '../order_service/controll.ers/order_service_controller.dart';
import '../turun_barang_offline_scanner/turun_barang_offline_scanner.dart';
import 'components/form_report_dialog.dart';
import '../order_service/order_service_screen.dart';
import 'components/take_evidence_dialog.dart';
import 'controllers/turun_barang_online_controller.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class TurunBarangOnlineScreen extends StatefulWidget {
  const TurunBarangOnlineScreen({Key? key}) : super(key: key);
  static String routeName = "/turun-barang-online";

  @override
  State<TurunBarangOnlineScreen> createState() =>
      _TurunBarangOnlineScreenState();
}

class _TurunBarangOnlineScreenState extends State<TurunBarangOnlineScreen> {
  Location location = Location();
  bool sjDibatalkan = false;

  late double latitude;
  late double longitude;
  bool locationGetted = false;
  TextEditingController textController = TextEditingController();
  TextEditingController TapperTextController = TextEditingController();

  String username = '';
  int totalBarangHarusDiTap = 0;

  final LocationSettings locationSettings = const LocationSettings(
    distanceFilter: 100,
  );
  String nomorSJOrder = "";

  Future<void> showUploadImageDialog(BuildContext context) async {
    final username = await SharedToken.univGetterString('username');
    LocationData locationData = await location.getLocation();

    final TextEditingController keteranganTxtController =
        TextEditingController();
    File? imageFile;
    final ImagePicker picker = ImagePicker();
    String keteranganGan = '';

    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());
    final sj = ctl.noSuratJalanSelected.value.toString().replaceAll(' ', '');

    // Function to pick image from camera or gallery
    Future<void> pickImage(ImageSource source) async {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      }
    }

    // Function to upload image to API
    Future<void> uploadImage(File imageFile) async {
      final plat_no = await SharedToken.univGetterString('no_plat');
      final String uploadUrl =
          '${kURL_ORIGIN}supir-titip-service?no_sj=$sj&keterangan=$keteranganGan&username=$username&lat=${locationData.latitude}&long=${locationData.longitude}&plat_no=${plat_no}';
      final mimeType = lookupMimeType(imageFile.path);
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ),
        );

      final response = await request.send();
      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Berhasil di upload',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        print('Image uploaded successfully.');
      } else {
        print('Failed to upload image.');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gambar gagal di upload',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red, // Change the background color here
            duration: Duration(
                seconds: 3), // Optional: Duration to display the snackbar
          ),
        );
      }
    }

    Future submitTitipService(File imageFile) async {
      final plat_no = await SharedToken.univGetterString('no_plat');
      final String uploadUrl =
          '${kURL_ORIGIN}supir-titip-service?no_sj=$sj&keterangan=$keteranganGan&username=$username&lat=${locationData.latitude}&long=${locationData.longitude}&plat_no=${plat_no}';
      final mimeType = lookupMimeType(imageFile.path);
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ),
        );

      final response = await request.send();
      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Berhasil di upload',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        print('Image uploaded successfully.');
      }
    }

    if (!mounted) return;

    // Show dialog to choose camera or gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to create a stateful dialog
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Upload foto bukti titip service (bila ada)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    onChanged: (value) {
                      keteranganGan = value;
                      print(value);
                    },
                    controller: keteranganTxtController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null, // Makes the TextFormField auto-expand
                    minLines: 1, // Minimum number of lines to display
                    decoration: const InputDecoration(
                      labelText: 'Isi Keterangan Lebih dulu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Foto SN barang'),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera'),
                    onPressed: () async {
                      Navigator.pop(context); // Close the dialog
                      await pickImage(ImageSource.camera);
                      if (imageFile != null) {
                        await uploadImage(imageFile!);
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () async {
                      Navigator.pop(context); // Close the dialog
                      await pickImage(ImageSource.gallery);
                      if (imageFile != null) {
                        await uploadImage(imageFile!);
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop(keteranganTxtController.text);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    final sj = ctl.noSuratJalanSelected.value.toString().replaceAll(' ', '');

    if (mounted) {
      setState(() {
        nomorSJOrder = sj;
      });
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // showUploadImageDialog(context);
      formReportDialog(context);
    });
    _getLocationData();
    _getCountProduct();
    SharedToken.univGetterString('username').then((value) {
      if (mounted) {
        SharedToken.univGetterString('no_plat').then((no_plat) {
          if (mounted) {
            setState(() {
              TapperTextController.text = '${value} (${no_plat}) ';
            });
          }
        });
      }
    });
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
      // do what you want to do with the position here
      if (mounted) {
        setState(() {
          // currentLocation = LatLng(position!.latitude, position!.longitude);
          _addLokasiFirebaseFromLok(position!);
        });
      }
    }, onError: (error) {
      print("Error getting location: $error");
      // Handle error appropriately
    });
    // Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
    //   try {
    //     await _getLocationData();
    //   } catch (e) {
    //     // Handle the exception as per your requirement
    //     print('Error we: $e');
    //   }
    // });
  }

  _getLocationData() async {
    try {
      print('nigger');
      LocationData locationData = await location.getLocation();
      if (mounted) {
        setState(() {
          print('yyee nigger');

          latitude = locationData.latitude!;
          longitude = locationData.longitude!;
          textController.text = '${latitude}, ${longitude}';
          locationGetted = true;
          final TurunBarangOnlineController ctl =
              Get.put(TurunBarangOnlineController());
          ctl.coordinate['lat'] = latitude.toString();
          ctl.coordinate['long'] = longitude.toString();
        });

        print(textController.text);
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  List<Map<String, dynamic>> output = [];
  var listBarangTapped = [];

  Future<void> _postRequestSJDone(String nomorSJ) async {
    nomorSJ = nomorSJ.replaceAll(' ', '');
    final String apiUrl =
        kURL_ORIGIN + 'sale-wholesale/save-sj-done?no_sj=$nomorSJ';

    Map<String, dynamic> data = {
      'key1': 'value1',
      'key2': 'value2',
    };
    String jsonData = jsonEncode(data);
    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  _getCountProduct() async {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    Map<String, int> productCount = {};
    Map<String, int> totalQtyMap = {};

    ctl.listInv.value = await DatabaseHelper.instance
        .getInventoryProductValidationByNomorSJ(ctl.nomorSJ.value);

    if (ctl.listInv.isEmpty) {
      for (var item in ctl.listInv) {
        String productName = item['product_name'] ?? 'Unknown??';
        int totalQty = await DatabaseHelper.instance
            .countBarangTap(item['product_name'], item['no_order']);

        final barangTap = await DatabaseHelper.instance.getAllBarangTap(
            item['product_name'], item['no_order'], item['inventory_id']);

        listBarangTapped.addAll(barangTap);

        productCount[productName] = (productCount[productName] ?? 0) + 1;
        totalQtyMap[productName] = totalQty;

        item['nomor_sj'] = ctl.nomorSJ.value;

        await DatabaseHelper.instance.insertInventoryProductValidation(item);
      }
    }

    if (ctl.listInv.isEmpty) {
      ctl.listInv.value = await DatabaseHelper.instance
          .getInventoryProductValidationByNomorSJ(ctl.nomorSJ.value);
      print(ctl.listInv);

      if (ctl.listInv.isNotEmpty) {
        for (var item in ctl.listInv) {
          String productName = item['product_name'] ?? 'Unknown??';
          int totalQty = await DatabaseHelper.instance
              .countBarangTap(item['product_name'], item['no_order']);

          final barangTap = await DatabaseHelper.instance
              .getAllBarangTapV2(item['inventory_id']);

          print('barangTap es');
          print(barangTap);

          listBarangTapped.addAll(barangTap);

          productCount[productName] = (productCount[productName] ?? 0) + 1;
          totalQtyMap[productName] = totalQty;
        }
      }
    }

    List listBarangTappedTemp = [];

    listBarangTapped.forEach((element) {
      var productExists = listBarangTappedTemp
          .where((el) => el['product_name'] == element['product_name'])
          .toList();

      if (productExists.isNotEmpty) {
        productExists[0]['sn'].add(element['sn']);
      } else {
        listBarangTappedTemp.add({
          'product_name': element['product_name'],
          'sn': [element['sn']]
        });
      }
    });
    int matchingQuantities = 0;

    if (mounted) {
      setState(() {
        listBarangTapped = listBarangTappedTemp;
      });
    }

    productCount.forEach((productName, count) {
      totalBarangHarusDiTap += count;

      var tapped = totalQtyMap[productName] ?? 0;

      listBarangTapped.forEach((item) {
        if (item['product_name'] == productName) {
          tapped = item['sn'].length;
        }
      });
      if (mounted) {
        setState(() {
          output.add({
            "product_name": productName,
            "qty": count,
            "qty_tap": tapped,
          });
        });
      }
    });

    if (mounted) {
      setState(() {
        output.sort((a, b) {
          var qtyA = a["qty"] as int;
          var qtyTapA = a["qty_tap"] as int;
          var qtyB = b["qty"] as int;
          var qtyTapB = b["qty_tap"] as int;

          if (qtyTapA < qtyA && qtyTapB < qtyB) {
            return qtyTapA.compareTo(qtyTapB);
          } else if (qtyTapA < qtyA) {
            return -1; // "a" comes first
          } else if (qtyTapB < qtyB) {
            return 1; // "b" comes first
          } else {
            return qtyA.compareTo(qtyB);
          }
        });
      });
    }

    for (var currentItem in output) {
      bool quantitiesMatch = currentItem['qty_tap'] == currentItem['qty'];

      if (quantitiesMatch) {
        matchingQuantities += currentItem['qty_tap'] as int;
      }

      if (matchingQuantities == totalBarangHarusDiTap) {
        for (var element in ctl.listSJ) {
          final data = {
            "nomor_order": element['nomor_order'],
            "nama_toko": element['toko'],
            "creator": username,
            "status": "unvalidasi",
            "customer_nama": "DUMMY",
            "customer_notelp": "DUMMY",
            "supir": username,
            "tapper": username
          };
          DatabaseHelper.instance.insertHistorySuratJalan(data).then((value) =>
              {
                _postRequestSJDone(element['nomor_order']),
                sJDalamPengiriman("2")
              });
        }
      }
    }
  }

  Future sJDalamPengiriman(String statusval) async {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    final url =
        Uri.parse('${kURL_ORIGIN}pengiriman/update-pengiriman-from-mobile');
    final sj = ctl.noSuratJalanSelected.value.toString().replaceAll(' ', '');
    Map<String, dynamic> requestBody = {"sj": "'$sj'", "status": statusval};

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('POST request successful! Response:');
        print(response.body);
      } else {
        print('POST request failed with status: ${response.statusCode}');
        print(response.body);
      }
    } catch (error) {
      print('Error making POST request: $error');
    }
  }

  Future<List<bool>> fetchCompletionStatuses() async {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    List<bool> completionStatuses = [];

    for (var i = 0; i < ctl.listInv.length; i++) {
      var e = await ctl.detectCompletionItem(
          ctl.listInv[i]['no_order'], ctl.listInv[i]['inventory_id']);
      completionStatuses.add(e);
    }
    return completionStatuses;
  }

  String stringCensor(String inputString) {
    var prefix = inputString.substring(0, 5);

    var suffix = inputString.substring(inputString.length - 4);

    var outputString = "$prefix*********$suffix";

    return outputString;
  }

  void _launchMapsUrl(List listLoc) async {
    String destUrl = '';
    for (var i = 0; i < listLoc.length; i++) {
      if (i == 0) {
        destUrl += latitude.toString() + ',' + longitude.toString() + '/';
      }
      destUrl += listLoc[i]['dest_loc_latitude'] +
          ',' +
          listLoc[i]['dest_loc_longitude'] +
          '/';
    }

    final url = 'https://www.google.com/maps/dir/${destUrl}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _addLokasiFirebaseFromLok(Position currentPosition) async {
    DateTime timestamp = DateTime.now();

    String curTimeStamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);

    var uuid = const Uuid();
    String username = await SharedToken.univGetterString('username');
    username = username.replaceAll(' ', '_');
    String timestampLink = DateFormat('dd-MM-yyyy').format(timestamp);

    // final String userId = username.toString() + '_' + uuid.v4().toString();
    final DatabaseReference dblokRef =
        FirebaseDatabase.instance.ref('sima_pengiriman_supir');

    // final String username = await SharedToken.univGetterString('username');

    final DatabaseReference livelokRef = FirebaseDatabase.instance
        .ref('perjalanan_supir_${username}_${timestampLink}');
    final MapsViewController ctl = Get.put(MapsViewController());
    try {
      final liveLokRefData = ctl.liveLokRefData;

      liveLokRefData['lat_cur'] = currentPosition.latitude;
      liveLokRefData['long_cur'] = currentPosition.longitude;
      liveLokRefData['updated_at'] = curTimeStamp;

      // await livelokRef.set(liveLokRefData);

      await dblokRef.push().set({
        'created_at': curTimeStamp,
        'supir': username,
        'cur_long': currentPosition.longitude,
        'cur_lat': currentPosition.latitude,
        'id': uuid.v4()
      });

      final DatabaseReference dashboardLive =
          FirebaseDatabase.instance.ref('realtime_supir_dashboard/${username}');

      await dashboardLive.set({
        "lat": currentPosition.latitude.toString(),
        "long": currentPosition.longitude.toString()
      });
      //FIREBASE BUAT DASHBOARD
      print('User added successfully!');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  bool evidenceTaken = false;
  var attachments = [];

  final keteranganTxt = TextEditingController();
  void _openFullScreen(BuildContext context, XFile img) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black87,
          alignment: Alignment.center,
          child: Image.file(
            File(img.path),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _showTakeEvidncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bukti Turun Barang'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flexible widget to use 30% of the available height
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var item in attachments)
                            InkWell(
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
                                    fit: BoxFit
                                        .cover, // Optional: fit the image within the SizedBox
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.white,
                                        child: const Center(
                                          child: Text(
                                            'Not Found',
                                            style:
                                                TextStyle(color: Colors.black),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _images.map((img) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
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
                            evidenceTaken = true;
                          });
                          await _pickImgFromGallery();
                        },
                        child: const Text('Galeri'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          evidenceTaken = true;
                          await _pickImgFromCamera();
                        },
                        child: const Text('Kamera'),
                      ),
                    ],
                  ),
                  Text('File Selected : $_imageNames'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: keteranganTxt,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan', // Label for the text area
                      border: OutlineInputBorder(), // Optional: Add a border
                    ),
                    maxLines: null, // Allows unlimited lines
                    keyboardType:
                        TextInputType.multiline, // Enables multi-line input
                  )
                ],
              ),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                if (keteranganTxt.text.isEmpty) {
                  final snackBar = SnackBar(
                    content: const Text('KETERANGAN WAJIB DI ISI!'),
                    action: SnackBarAction(
                      label: 'Close',
                      onPressed: () {
                        // Code to undo the action
                      },
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  return;
                }

                await uploadFile();

                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final ImagePicker _picker = ImagePicker();

  // Hold picked images
  List<XFile> _images = [];
  // Optionally hold just names or paths for display
  List<String> _imageNames = [];
  List<String> _imagePaths = [];

  final TextEditingController _keteranganTxt = TextEditingController();

  Future<void> _pickImgFromGallery() async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked == null || picked.isEmpty) return;

    setState(() {
      _images = picked;
      _imageNames = picked.map((img) => img.name).toList();
      _imagePaths = picked.map((img) => img.path).toList();
    });
  }

  /// If you really want to allow multiple camera shots in one go,
  /// you could call pickImage repeatedly in a loop/callback.
  Future<void> _pickImgFromCamera() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.camera);
    if (img == null) return;

    setState(() {
      _images.add(img);
      _imageNames.add(img.name);
      _imagePaths.add(img.path);
    });
  }

  Future<void> uploadFile() async {
    if (_images.isEmpty) return;

    try {
      final uname = await SharedToken.univGetterString('username');
      final platNo = await SharedToken.univGetterString('no_plat');
      final locData = await Location().getLocation();

      final ctk = Get.put(MenuSelectCustomerController());
      final ctl = Get.put(TurunBarangOnlineController());

      // Offline: save tasks locally
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

      // Online: upload each image one by one
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

  Future<void> showBarangPrioritas(BuildContext context, dynamic items) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user can tap outside the dialog to dismiss it
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Item Prioritas'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                if (items[index]['product_name'] != null) {
                  return ListTile(
                    title: Text(items[index]['product_name']),
                    subtitle: items[index]['inventory_id'] != null
                        ? Text(items[index]['inventory_id'])
                        : const Text('Belum di out'),
                  );
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isMoved = false;

  @override
  Widget build(BuildContext context) {
    final TurunBarangOnlineController ctl =
        Get.put(TurunBarangOnlineController());

    MenuSelectCustomerController ctr = Get.put(MenuSelectCustomerController());
    TextEditingController textController = TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Turun Barang",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            Obx(() => ctl.hasPriority == true
                ? IconButton(
                    color: Colors.red,
                    onPressed: () {
                      List<Map<String, dynamic>> listBarangPrioritas =
                          List<Map<String, dynamic>>.from(
                              ctl.listBarangPrioritas);
                      showBarangPrioritas(context, listBarangPrioritas);
                    },
                    icon: const Icon(Icons.warning_amber_outlined))
                : Container())
          ],
        )),
      ),
      body: WillPopScope(
        onWillPop: () async {
          final snackBarWarnYetTakeEvidnc = SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
                'Anda belum mengambil bukti barang turun, tetap ke menu?',
                style: TextStyle(color: Colors.white)),
            action: SnackBarAction(
              label: 'Ya',
              onPressed: () {
                // ctl.listInv.clear();
                Navigator.pushReplacementNamed(
                    context, MenuSelectCustomer.routeName);
              },
            ),
          );

          // Use the ScaffoldMessenger to show the SnackBar
          if (!evidenceTaken) {
            ScaffoldMessenger.of(context)
                .showSnackBar(snackBarWarnYetTakeEvidnc);
            return false;
          }

          ctl.listInv.clear();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MenuScreen(),
              ));
          return false;
        },
        child: DefaultTabController(
          length: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: TapperTextController,
                  enabled: false,
                  onChanged: (value) {
                    ctl.tapper.value = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tapper',
                    labelStyle: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 17,
                  ),
                ),
                const TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Tab(text: 'List'),
                    Tab(text: 'Hasil Tap'),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView.builder(
                          itemCount: output.length,
                          itemBuilder: ((context, index) {
                            if (output[index]['qty_tap'] ==
                                output[index]['qty']) {
                              return ListTile(
                                title: Text(
                                  '${output[index]['product_name']}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                                trailing: Text(
                                  '${output[index]['qty_tap']}/${output[index]['qty']}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              );
                            }

                            return ListTile(
                              title: Text('${output[index]['product_name']}'),
                              trailing: Text(
                                  '${output[index]['qty_tap']}/${output[index]['qty']}'),
                            );
                          })),
                      ListView.builder(
                        itemCount: listBarangTapped.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var item in listBarangTapped[index]['sn'])
                                  Text(stringCensor(item)),
                              ],
                            ),
                            title:
                                Text(listBarangTapped[index]['product_name']),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // AnimatedPositioned(
                      //   duration: Duration(seconds: 1),
                      //   left: _isMoved ? -200 : 0, // Move left by 200 pixels
                      //   top: 0,
                      //   child: AnimatedOpacity(
                      //     duration: Duration(milliseconds: 500),
                      //     opacity: _isMoved ? 0.0 : 1.0, // Disappear when moved
                      //     child: Container(
                      //       width: 100,
                      //       height: 100,
                      //       color: Colors.blue,
                      //     ),
                      //   ),
                      // ),

                      // IconButton that expands
                      ExpansionTile(
                        leading: const Icon(Icons.expand_more), // Icon button
                        title: const Text('Klik untuk buka '),
                        children: [
                          Container(
                            // Constraining the max height to half the screen height
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // ctr.internetConnected == true ?
                                  SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: locationGetted &&
                                                      !sjDibatalkan
                                                  ? Colors.blue
                                                  : Colors.blue[200]),
                                          onPressed: () async {
                                            if (!sjDibatalkan) {
                                              sJDalamPengiriman("17");
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UniversalScannerSCreen(
                                                          goBackRouteName:
                                                              TurunBarangOnlineScreen
                                                                  .routeName),
                                                ),
                                              );
                                            }
                                          },
                                          child: locationGetted
                                              ? const Text(
                                                  'Scan SN dan Identifier',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : Text(
                                                  'Getting current location..',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)))),
                                  // : SizedBox(
                                  //     width: double.infinity,
                                  //     child: ElevatedButton(
                                  //       style: ElevatedButton.styleFrom(
                                  //           backgroundColor: Colors.blue),
                                  //       onPressed: () {
                                  //         Navigator.pushNamed(
                                  //             context,
                                  //             TurunBarangOfflineScanner
                                  //                 .routeName);
                                  //       },
                                  //       child: Text('Scan SN',
                                  //           style: TextStyle(
                                  //               color: Colors.white)),
                                  //     ),
                                  //   ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // await getAttachment();
                                        // // _launchMapsUrl(ctl.listLoc);
                                        // // return;
                                        Navigator.pushReplacementNamed(context,
                                            BarangTidakMuatScreen.routeName);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey),
                                      child: const Text('Barang tidak muat',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await getAttachment();
                                        // _launchMapsUrl(ctl.listLoc);
                                        // return;

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TakeEvidenceDialog()),
                                        );

                                        // _showTakeEvidncDialog(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple),
                                      child: const Text('Foto Bukti',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: ctl.barangTap.value == 0
                                            ? Colors.red
                                            : Colors
                                                .red[200], // Background color
                                        onPrimary: Colors.white, // Text color
                                        elevation: 5, // Elevation (shadow)
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              25), // Button border radius
                                        ),
                                      ),
                                      onPressed: () {
                                        // Show dialog when the button is pressed
                                        if (ctl.barangTap.value == 0) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'SJ Pending Kirim'),
                                                content: Text(
                                                    'Sebutkan Alasan untuk SJ ${ctl.nomorSJ} Pending'),
                                                actions: <Widget>[
                                                  TextFormField(
                                                    controller: ctl
                                                        .alasanBataltextController,
                                                    maxLines: 10,
                                                  ),
                                                  TextButton(
                                                      onPressed: () async {
                                                        await ctl.SJBatalKirim(
                                                            context);
                                                        if (mounted) {
                                                          setState(() {
                                                            sjDibatalkan = true;
                                                          });
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Ok'))
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: const Text('Batal/Gagal Kirim'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _launchMapsUrl(ctl.listLoc);
                                        return;
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      child: const Text('Buka Maps',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: double.infinity,
                                  //   child: ElevatedButton(
                                  //     onPressed: () async {
                                  //       var request = http.Request(
                                  //           'POST',
                                  //           Uri.parse(
                                  //               '${kURL_ORIGIN}supir-get-toko-from-sj?nomer_surat_jalan=SJ-24-03-26-0007'));

                                  //       http.StreamedResponse response =
                                  //           await request.send();

                                  //       if (response.statusCode == 200) {
                                  //         var resp = await response.stream
                                  //             .bytesToString();

                                  //         var jsonResponse = jsonDecode(resp);

                                  //         if (!jsonResponse['success']) {
                                  //           SnackBar(
                                  //             content: Text(
                                  //                 '${jsonResponse['msg']}'),
                                  //             action: SnackBarAction(
                                  //               label: 'Undo',
                                  //               onPressed: () {
                                  //                 // Code to execute when "Undo" is pressed
                                  //                 print('Undo action pressed!');
                                  //               },
                                  //             ),
                                  //           );

                                  //           return;
                                  //         }

                                  //         if (!mounted) return;

                                  //         showDialog(
                                  //           barrierDismissible: false,
                                  //           context: context,
                                  //           builder: (context) {
                                  //             return StatefulBuilder(
                                  //               builder: (context, setState) {
                                  //                 return AlertDialog(
                                  //                   title: Text('TOKO'),
                                  //                   content: Column(
                                  //                     mainAxisSize:
                                  //                         MainAxisSize.min,
                                  //                     children: [
                                  //                       for (var item
                                  //                           in jsonResponse[
                                  //                               'result'])
                                  //                         ElevatedButton(
                                  //                             onPressed: () {
                                  //                               final OrderServiceController
                                  //                                   ctl =
                                  //                                   Get.put(
                                  //                                       OrderServiceController());

                                  //                               ctl.saleWholesaleCustomerIdSelected
                                  //                                       .value =
                                  //                                   int.parse(item[
                                  //                                       'swc_id']);

                                  //                               ctl.saleWholesaleCustomerNamenAddress[
                                  //                                       'address'] =
                                  //                                   item[
                                  //                                       'swc_address'];

                                  //                               ctl.saleWholesaleCustomerNamenAddress[
                                  //                                       'customer_name'] =
                                  //                                   '${item['swc_shop_name']} (${item['swc_fullname']})';

                                  //                               Navigator.pushReplacementNamed(
                                  //                                   context,
                                  //                                   OrderServiceScreen
                                  //                                       .routeName);
                                  //                             },
                                  //                             child: Text(
                                  //                                 '${item['swc_shop_name']} (${item['swc_fullname']})'))
                                  //                     ],
                                  //                   ),
                                  //                   actions: [
                                  //                     TextButton(
                                  //                       onPressed: () {
                                  //                         Navigator.of(context)
                                  //                             .pop();
                                  //                       },
                                  //                       child: Text('Close'),
                                  //                     ),
                                  //                   ],
                                  //                 );
                                  //               },
                                  //             );
                                  //           },
                                  //         );
                                  //       } else {
                                  //         print(response.reasonPhrase);
                                  //         SnackBar(
                                  //           content: Text(
                                  //               '${response.reasonPhrase}'),
                                  //           action: SnackBarAction(
                                  //             label: 'Undo',
                                  //             onPressed: () {
                                  //               // Code to execute when "Undo" is pressed
                                  //               print('Undo action pressed!');
                                  //             },
                                  //           ),
                                  //         );
                                  //       }
                                  //     },
                                  //     style: ElevatedButton.styleFrom(
                                  //         backgroundColor: Colors.orange),
                                  //     child: Text('Service Titipan',
                                  //         style:
                                  //             TextStyle(color: Colors.white)),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          const CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
