import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sima_pengiriman/screens/order_service/components/product_select_component.dart';

import '../controll.ers/order_service_controller.dart';

class OrderServiceScannerSnScreen extends StatefulWidget {
  const OrderServiceScannerSnScreen({super.key});

  static String routeName = '/order-service-sn-scanner';

  @override
  State<OrderServiceScannerSnScreen> createState() =>
      _OrderServiceScannerSnScreenState();
}

class _OrderServiceScannerSnScreenState
    extends State<OrderServiceScannerSnScreen> {
  MobileScannerController controller = MobileScannerController();
  @override
  void initState() {
    super.initState();
    controller.start();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showCustomDialog(context);
    // });
  }

  String sn = '';
  String inputText = '';

  void showCustomDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('SN TERDETEKSI'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        inputText = value;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Enter something'),
                  ),
                  SizedBox(height: 20),
                  ProductSelectComponent(),
                  SizedBox(height: 20),
                  Text('NO SN: $sn'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final OrderServiceController ctl =
                        Get.put(OrderServiceController());
                    ctl.listSnProduct
                        .add({'sn': sn, 'product_id': ctl.productIdSelected});
                    controller.start();
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR/Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                if (state == TorchState.off) {
                  return Icon(Icons.flash_off);
                } else {
                  return Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (barcode) async {
          controller.stop();

          barcode.barcodes[0].rawValue!;
          if (barcode.barcodes.isNotEmpty) {
            setState(() {
              sn = barcode.barcodes[0].rawValue!;
            });
          }

          showCustomDialog(context);
          // var barcode = barcodes[0].rawValue;
          // if (barcode.rawValue == null) {
          //   debugPrint('Failed to scan Barcode');
          // } else {
          //   final String code = barcode.rawValue!;
          //   debugPrint('Barcode found! $code');
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('Barcode: $code')),
          //   );
          // }
        },
      ),
    );
  }
}
