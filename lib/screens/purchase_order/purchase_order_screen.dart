import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../controllers/list_po_controller.dart';
import '../../enums.dart';
import './components/body.dart';

class ListPoScreen extends StatelessWidget {
  static var routeName = '/listBt';
  ListPoScreen({Key? key}) : super(key: key);

  final TextEditingController _textEditingController = TextEditingController();

  // void _handleEditingComplete() {
  //   String enteredText = _textEditingController.text;
  //   // Perform desired actions with enteredText
  //   print('Entered text: $enteredText');
  // }

  @override
  Widget build(BuildContext context) {
    final ListPoController ctl = Get.put(ListPoController());
    return Scaffold(
      appBar: AppBar(
          title: Container(
        alignment: Alignment.centerLeft,
        color: Colors.white,
        child: TextField(
          controller: _textEditingController,
          onEditingComplete: () async {
            await ctl.searchByTxt(_textEditingController.text);
          },
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            hintText: 'Search',
          ),
        ),
      )),
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
