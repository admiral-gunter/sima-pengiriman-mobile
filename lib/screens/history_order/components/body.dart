import 'package:flutter/material.dart';

import '../../../helper/debouncer.dart';
import '../../summary_order/summary_order_screen.dart';

class Body extends StatelessWidget {
  Body({super.key});
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onChanged: (value) {
            _debouncer.run(() {
              print('Action after 0.5 seconds: $value');
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari Order...', // Placeholder text
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item $index'),
                subtitle: Text('This is a dummy item.'),
                leading: Icon(Icons.circle), // Just for illustration
                onTap: () {
                  Navigator.pushReplacementNamed(
                      context, SummaryOrderScreen.routeName);
                  print('Tapped on item $index');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
