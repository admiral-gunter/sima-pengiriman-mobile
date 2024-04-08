import 'package:flutter/material.dart';
import 'package:async/async.dart'; // Import the async package
import '../../../helper/debouncer.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onChanged: (value) {
            _debouncer.run(() {
              // Perform your action here
              print('Action after 0.5 seconds: $value');
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari Order...', // Placeholder text
          ),
        ), // You can adjust this TextField as per your requirement
        Expanded(
          child: ListView.builder(
            itemCount: 50, // Number of dummy items
            itemBuilder: (context, index) {
              // Generate a dummy item
              return ListTile(
                title: Text('Order NO : GO-08042024-$index'),
                subtitle: Text('Customer Dummy.'),
                trailing:
                    Text('Incomplete', style: TextStyle(color: Colors.orange)),
                leading: Icon(Icons.circle), // Just for illustration
                onTap: () {
                  // Action to perform when the item is tapped
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
