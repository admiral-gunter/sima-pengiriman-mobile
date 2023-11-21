import 'package:flutter/material.dart';
import 'package:sima_pengiriman/screens/sign_in/components/bodyv2.dart';

import '../../size_config.dart';

class SignInScreen extends StatelessWidget {
  static String routeName = "/sign_in";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: BodyV2(),
    );
  }
}
