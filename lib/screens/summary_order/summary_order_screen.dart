import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:sima_pengiriman/screens/delivery_order_menu/delivery_order_menu.dart';
import '../../shared_preferences/shared_token.dart';
import 'components/body.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';

class SummaryOrderScreen extends StatefulWidget {
  static String routeName = "/summaryOrder";
  SummaryOrderScreen({super.key});

  @override
  State<SummaryOrderScreen> createState() => _SummaryOrderScreenState();
}

class _SummaryOrderScreenState extends State<SummaryOrderScreen> {
  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  var generatedOrderCode = '';

  generatePDF(BuildContext context) async {
    try {
      final orderCd =
          await SharedToken.univGetterString('generated_order_code');
      if (mounted) {
        setState(() {
          generatedOrderCode = orderCd;
        });
      }
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: generatedOrderCode,
              width: double.infinity,
              height: 200,
            ),
          ),
        ),
      );

      final output = await getDownloadPath();
      final file = File("${output}/ORDER_$generatedOrderCode.pdf");

      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      // Show error message
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error generating PDF: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Summary Order"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, DeliverOrderMenu.routeName);
          },
        ),
      ),
      body: const Padding(padding: EdgeInsets.all(10), child: Body()),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help),
                  Text('Help'),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
              child: ElevatedButton(
                  onPressed: () async {
                    await generatePDF(context);
                    Future.delayed(Duration(seconds: 1), () {
                      OpenFile.open(
                          "/sdcard/Download/ORDER_$generatedOrderCode.pdf");
                    });
                  },
                  child: Text('Download')))
        ],
      ),
    );
  }
}
