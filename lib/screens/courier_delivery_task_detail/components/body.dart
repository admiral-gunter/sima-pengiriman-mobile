import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incomplete',
                style: TextStyle(color: Colors.orange),
              ),
              Text('Order Date')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order NO : GO-09875433 ',
              ),
              Text('15 Mar 2023, 01:09 ')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Weight',
              ),
              Text('8kg')
            ],
          ),
          Container(
            decoration: BoxDecoration(color: Colors.grey[300]),
            height: 1,
            margin: EdgeInsets.symmetric(vertical: 10),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.black, // Border color
                width: 0.5, // Adjust this value for the thickness
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup Address'),
                    Text(
                      'Isi Alamat',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Icon(Icons.attachment, color: Colors.purple),
                          Text(
                            'Add attachment',
                            style: TextStyle(color: Colors.purple),
                          )
                        ]),
                      ),
                    ),
                    Text('picked up from muh rafli'),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Open Maps'),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.black, // Border color
                width: 0.5, // Adjust this value for the thickness
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Address'),
                    Text(
                      'Isi Alamat',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Icon(Icons.attachment, color: Colors.green),
                          Text(
                            'Add attachment',
                            style: TextStyle(color: Colors.green),
                          )
                        ]),
                      ),
                    ),
                    Text('received by muh rafli'),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Open Maps'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
