import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sima_pengiriman/constants.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/screens/menu_select_customer/menu_select_customer.dart';
import 'package:sima_pengiriman/screens/order_service/components/order_service_scanner_sn.dart';
import '../../../shared_preferences/shared_token.dart';
import '../../menu_select_customer/controllers/menu_select_customer_controller.dart';
import '../components/product_select_component.dart';
import '../controll.ers/order_service_controller.dart';
import 'inventory_location_select_component.dart';
import 'select_sale_wholesale_customer_component.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool tidakMuatIsChecked = false;

  final ImagePicker _picker = ImagePicker();
  final List<File> _imageList = [];
  final List<String> _imageListStr = [];

  final TextEditingController keteranganTxtController = TextEditingController();

  // Method to pick image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageListStr.add(pickedFile.path);
      setState(() {
        _imageList.add(File(pickedFile.path));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final OrderServiceController ctl = Get.put(OrderServiceController());
    ctl.listSnProduct.clear();
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width * 0.10;
    double imageListHeight = MediaQuery.of(context).size.height * 0.4;
    final OrderServiceController ctl = Get.put(OrderServiceController());
    final MenuSelectCustomerController ctk =
        Get.put(MenuSelectCustomerController());
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensure the layout adjusts for the keyboard
      body: SafeArea(
        child: ListView(
          children: [
            // Container to constrain the height of the image list
            SizedBox(
              height: imageListHeight,
              child: _imageList.isEmpty
                  ? const Center(child: Text('Pilih Bukti foto.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            3, // Adjust this based on the number of columns you want
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _imageList.length,
                      scrollDirection:
                          Axis.horizontal, // Enable horizontal scrolling
                      itemBuilder: (context, index) {
                        return Image.file(
                          _imageList[index],
                          width: imageSize, // 5% of screen width
                          height: imageSize, // Maintain square aspect ratio
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: _pickImage,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, OrderServiceScannerSnScreen.routeName);
                          },
                          child: const Text('Scan SN'))
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), // Add some space between elements
            // Multiple text fields
            TextFormField(
              controller: keteranganTxtController,
              decoration: const InputDecoration(
                labelText: "Keterangan",
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null, // Makes it auto-expand
              minLines: 1, // Starts with a single line
            ),
            const SizedBox(height: 20),

            ctk.internetConnected.value
                ? const InventoryLocationSelectComponent()
                : SizedBox.shrink(),
            const SizedBox(height: 20),
            Wrap(
              crossAxisAlignment:
                  WrapCrossAlignment.center, // Center vertically
              children: [
                Checkbox(
                  value: tidakMuatIsChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      tidakMuatIsChecked = newValue ??
                          false; // Update the state when checkbox changes
                    });
                  },
                ),
                const Text('Barang tidak muat ')
              ],
            ),
            const SizedBox(height: 20),

            // SelectSaleWholesaleCustomerComponent(),
            Text(ctl.saleWholesaleCustomerNamenAddress['customer_name'] ?? ''),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final MenuSelectCustomerController kty =
                    Get.put(MenuSelectCustomerController());
                final username = await SharedToken.univGetterString('username');
                final platNo = await SharedToken.univGetterString('no_plat');
                if (!kty.internetConnected.value) {
                  //              String file,
                  // String platNo,
                  // String nomorOrder,
                  // String username,
                  // String keterangan,
                  // String latitude,
                  // String longitude
                  DateTime now = DateTime.now();
                  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                  var insertDataOrderService = {
                    'keterangan': keteranganTxtController.text,
                    'username': username,
                    'location_id': '0',
                    'plat_no': platNo,
                    'date_added': formattedDate
                  };

                  int insertedId = await DatabaseHelper.instance
                      .insertOrderService(insertDataOrderService);
                  ctl.listSnProduct.map((item) async {
                    await DatabaseHelper.instance.insertOrderServicesOfflineSn(
                        item['sn'], '0', insertedId);
                    // return {
                    //   'sn': item['sn'],
                    //   'product_id': item['product_id']
                    //       .value, // Use .value to get the int value from RxInt
                    // };
                  });

                  for (var i = 0; i < _imageListStr.length; i++) {
                    await DatabaseHelper.instance
                        .insertOrderServicesOfflineAttachment(
                            _imageListStr[i], insertedId);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: const Text('Upload berhasil!'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () {
                          // Code to execute when the user presses the button
                        },
                      ),
                    ),
                  );
                  return;
                }

                if (keteranganTxtController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Keterangan tidak boleh kosong!'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () {
                          // Code to execute when the user presses the button
                        },
                      ),
                    ),
                  );
                  return;
                }

                if (_imageList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Foto tidak boleh kosong!'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () {
                          // Code to execute when the user presses the button
                        },
                      ),
                    ),
                  );
                  return;
                }

                if (ctl.inventoryLocationIdSelected.value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Lokasi boleh kosong!'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () {
                          // Code to execute when the user presses the button
                        },
                      ),
                    ),
                  );
                  return;
                }

                print('test');

                try {
                  final apiUrl =
                      // ignore: unnecessary_brace_in_string_interps
                      '${kURL_ORIGIN}supir-titip-service?keterangan=${keteranganTxtController.text}&username=$username&location_id=${ctl.inventoryLocationIdSelected.value}&plat_no=${platNo}&barang_tidak_muat=${tidakMuatIsChecked}';

                  print(ctl.listSnProduct);

                  final dataToSend = ctl.listSnProduct.map((item) {
                    return {
                      'sn': item['sn'],
                      'product_id': item['product_id']
                          .value, // Use .value to get the int value from RxInt
                    };
                  }).toList();
                  final dataSend = jsonEncode(dataToSend);

                  print(apiUrl);

                  await ctl.uploadImagesAndFormData(
                      _imageList, {'data_send': dataSend}, apiUrl);

                  if (ctl.uploadsukses.value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: const Text('Upload berhasil!'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'Close',
                          onPressed: () {
                            // Code to execute when the user presses the button
                          },
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: const Text('Upload Gagal!'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'Close',
                          onPressed: () {
                            // Code to execute when the user presses the button
                          },
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Error uploading: $e!'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () {
                          // Code to execute when the user presses the button
                        },
                      ),
                    ),
                  );
                  print('Error uploading: $e');
                }

                // ctl.uploadImagesAndFormData(
                //     _imageList, {'data_send': dataSend}, apiUrl);

                // try {

                // } catch (error) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       backgroundColor: Colors.red,
                //       content: Text('Error uploading: $error!'),
                //       duration: Duration(seconds: 2),
                //       action: SnackBarAction(
                //         label: 'Close',
                //         onPressed: () {
                //           // Code to execute when the user presses the button
                //         },
                //       ),
                //     ),
                //   );
                //   print('Error uploading: $error');
                // }
              },
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
