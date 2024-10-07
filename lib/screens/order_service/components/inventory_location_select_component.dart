import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sima_pengiriman/constants.dart';
import 'dart:convert';
import 'dart:io';
import '../controll.ers/order_service_controller.dart';
import '../model/product_select_modal.dart';

class ProductModel {
  final int id;
  final String text;

  ProductModel(this.id, this.text);
}

class InventoryLocationSelectComponent extends StatefulWidget {
  const InventoryLocationSelectComponent({super.key});

  @override
  State<InventoryLocationSelectComponent> createState() =>
      _InventoryLocationSelectComponentState();
}

class _InventoryLocationSelectComponentState
    extends State<InventoryLocationSelectComponent> {
  List<dynamic> options = []; // List to store API data
  List<dynamic> filteredOptions = []; // List for displaying filtered options
  String? selectedOption; // Variable to store selected value
  final TextEditingController searchController =
      TextEditingController(); // Controller for search input
  final TextEditingController menuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    menuController.addListener(_onFilterChanged);
    // fetchOptionsFromAPI(); // Fetch data when screen loads
  }

  List<ProductModel> menuItems = [
    ProductModel(1, 'loading..'),
  ];

  Future<void> fetchOptionsFromAPI() async {
    final url = Uri.parse(
        '${kURL_ORIGIN}supir-get-lokasi?keyword=${menuController.text}'); // Replace with your API URL

    // Define your request body (if needed)
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Successful response
        final data = jsonDecode(response.body);

        if (data['response'] is List) {
          setState(() {
            // Clear existing items if needed
            menuItems.clear();

            // Convert each item in the list to a ProductModel
            for (var item in data['response']) {
              menuItems.add(ProductModel(int.parse(item['id']), item['text']));
            }
          });

          print('Response data: $data');
        } else {
          print('Expected a list but got: ${data['response']}');
        }
      } else {
        // Handle error response
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      print('An error occurred: $e');
    }
  }

  void _onFilterChanged() {
    fetchOptionsFromAPI();
    // final query = _filterController.text.toLowerCase();
    setState(() {
      // filteredItems = menuItems.where((item) {
      //   return item.text.toLowerCase().contains(query);
      // }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 16.0;
    int selectedMenu;

    return DropdownMenu<ProductModel>(
      //initialSelection: menuItems.first,
      controller: menuController,
      width: width,
      hintText: "Pilih Lokasi",
      requestFocusOnTap: true,
      enableFilter: true,
      menuStyle: MenuStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(Colors.lightBlue.shade50),
      ),

      label: const Text('Pilih Lokasi'),
      onSelected: (ProductModel? menu) {
        final OrderServiceController ctl = Get.put(OrderServiceController());
        if (menu != null) {
          if (!mounted) return;

          setState(() {
            ctl.inventoryLocationIdSelected.value = menu.id;
            selectedMenu = menu.id;
          });
        }
      },
      dropdownMenuEntries:
          menuItems.map<DropdownMenuEntry<ProductModel>>((ProductModel menu) {
        return DropdownMenuEntry<ProductModel>(value: menu, label: menu.text);
      }).toList(),
    );
  }
}
