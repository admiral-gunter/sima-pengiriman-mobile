import 'package:flutter/material.dart';

import 'components/body.dart';

class MapsView extends StatelessWidget {
  const MapsView({super.key});
  static String routeName = 'maps-view';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Direction(),
    );
  }
}
