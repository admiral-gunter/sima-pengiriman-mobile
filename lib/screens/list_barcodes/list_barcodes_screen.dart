import 'package:flutter/material.dart';

import 'components/body.dart';

class ListBarcodesScreen extends StatelessWidget {
  static String routeName = "/list_barcodes";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Barcodes"),
      ),
      body: Body(),
    );
  }
}
