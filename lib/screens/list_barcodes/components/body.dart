import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../helper/database_helper.dart';

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<Map<String, dynamic>> _listScan = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final db = await DatabaseHelper.instance.database;
    final e = await db.query("scanned_data");
    setState(() {
      _listScan = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _listScan.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 80),
          height: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Code'),
                  Text('${_listScan[index]['id']}'),
                ],
              ),
              Center(
                  child: _listScan[index]['created_date'] != null
                      ? Text('${_listScan[index]['created_date']}')
                      : null),
            ],
          ),
        );
      },
    );
  }
}
