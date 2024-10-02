import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../model/product_select_modal.dart';

class MenuItem {
  final int id;
  final String label;
  final IconData icon;

  MenuItem(this.id, this.label, this.icon);
}

List<MenuItem> menuItems = [
  MenuItem(1, 'Home', Icons.home),
  MenuItem(2, 'Profile', Icons.person),
  MenuItem(3, 'Settings', Icons.settings),
  MenuItem(4, 'Favorites', Icons.favorite),
  MenuItem(5, 'Notifications', Icons.notifications),
  MenuItem(6, 'Messages', Icons.message),
  MenuItem(7, 'Explore', Icons.explore),
  MenuItem(8, 'Search', Icons.search),
  MenuItem(9, 'Chat', Icons.chat),
  MenuItem(10, 'Calendar', Icons.calendar_today),
];

class ProductSelectComponent extends StatefulWidget {
  const ProductSelectComponent({super.key});

  @override
  State<ProductSelectComponent> createState() => _ProductSelectComponentState();
}

class _ProductSelectComponentState extends State<ProductSelectComponent> {
  List<dynamic> options = []; // List to store API data
  List<dynamic> filteredOptions = []; // List for displaying filtered options
  String? selectedOption; // Variable to store selected value
  final TextEditingController searchController =
      TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    // fetchOptionsFromAPI(); // Fetch data when screen loads
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 16.0;
    final TextEditingController menuController = TextEditingController();
    MenuItem? selectedMenu;

    return DropdownMenu<MenuItem>(
      //initialSelection: menuItems.first,
      controller: menuController,
      width: width,
      hintText: "Pilih Product",
      requestFocusOnTap: true,
      enableFilter: true,
      menuStyle: MenuStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(Colors.lightBlue.shade50),
      ),

      label: const Text('Pilih Product'),
      onSelected: (MenuItem? menu) {
        setState(() {
          selectedMenu = menu;
        });
      },
      dropdownMenuEntries:
          menuItems.map<DropdownMenuEntry<MenuItem>>((MenuItem menu) {
        return DropdownMenuEntry<MenuItem>(value: menu, label: menu.label);
      }).toList(),
    );
  }
}
