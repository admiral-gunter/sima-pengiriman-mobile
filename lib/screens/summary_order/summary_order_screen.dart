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
        title: const Text("Summary Order"),
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
              child: ElevatedButton(onPressed: () {}, child: Text('Download')))
        ],
      ),
    );
  }
}
