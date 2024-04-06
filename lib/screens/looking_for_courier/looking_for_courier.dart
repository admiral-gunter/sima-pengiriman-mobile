import 'package:flutter/material.dart';
import 'components/body.dart';

class LookingForCourier extends StatelessWidget {
  static String routeName = 'looking-for-courier';
  const LookingForCourier({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
