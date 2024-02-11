import 'package:flutter/material.dart';

import 'components/body.dart';

class MapsView extends StatefulWidget {
  const MapsView({super.key, this.goBackRouteName});
  final dynamic goBackRouteName;
  static String routeName = 'maps-view';

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, widget.goBackRouteName),
        ),
        title: const Text('Maps'),
      ),
      body: Direction(),
    );
  }
}
