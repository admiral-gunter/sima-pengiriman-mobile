import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sima_pengiriman/screens/order_service/components/order_service_scanner_sn.dart';
import '../components/product_select_component.dart';
import '../controll.ers/order_service_controller.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _imageList = [];
  final TextEditingController keteranganTxtController = TextEditingController();

  // Method to pick image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
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
            ElevatedButton(
                onPressed: () async {
                  ctl.listSnProduct;

                  ctl.uploadImagesAndFormData(_imageList, {'': ''}, '');
                },
                child: const Text('Submit'))
          ],
        ),
      ),
    );
  }
}
