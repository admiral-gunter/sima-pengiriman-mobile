import 'package:flutter/material.dart';
import 'components/body.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';

class SummaryOrderScreen extends StatelessWidget {
  static String routeName = "/summaryOrder";
  SummaryOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Summary Order"),
      ),
      body: Padding(padding: EdgeInsets.all(10), child: Body()),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help),
                      Text('Help'),
                    ],
                  ))),
          SizedBox(
            width: 5,
          ),
          Expanded(
              child: ElevatedButton(onPressed: () {}, child: Text('Download')))
        ],
      ),
    );
  }
}
