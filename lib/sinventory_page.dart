import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryPage extends StatefulWidget {
  final int loggedInBranchId;

  const InventoryPage({super.key, required this.loggedInBranchId});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> items = [];
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();
  TextEditingController maxQuantityController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredItems = [];
  int? editingItemId;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    const url = 'http://localhost/minoriiproject/sinventory.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'fetch_items': '1',
        'branch_id': widget.loggedInBranchId.toString(),
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            items = List<Map<String, dynamic>>.from(data['items']).map((item) {
              return {
                'item_id': item['item_id'],
                'item_name': item['item_name'],
                'quantity': int.parse(item['quantity'].toString()),
                'max_quantity': int.parse(item['max_quantity'].toString()),
              };
            }).toList();
            filteredItems = List.from(items);
          });
        } else {
          print('Failed to fetch items: ${data['message']}');
        }
      } else {
        print('Error fetching items: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addItem(String name, String quantity, String maxQuantity) async {
    if (int.tryParse(quantity) == null || int.tryParse(maxQuantity) == null) {
      print('Invalid quantity or max quantity');
      return;
    }

    const url = 'http://localhost/minoriiproject/sinventory.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'add_item': '1',
        'item_name': name,
        'quantity': quantity,
        'max_quantity': maxQuantity,
        'branch_id': widget.loggedInBranchId.toString(),
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          fetchItems();
        } else {
          print('Failed to add item: ${data['message']}');
        }
      } else {
        print('Error adding item: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateItem(
      String name, String quantity, String maxQuantity) async {
    if (int.tryParse(quantity) == null || int.tryParse(maxQuantity) == null) {
      print('Invalid quantity or max quantity');
      return;
    }

    const url = 'http://localhost/minoriiproject/sinventory.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'update_item': '1',
        'item_id': editingItemId.toString(),
        'item_name': name,
        'quantity': quantity,
        'max_quantity': maxQuantity,
        'branch_id': widget.loggedInBranchId.toString(),
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          fetchItems();
        } else {
          print('Failed to update item: ${data['message']}');
        }
      } else {
        print('Error updating item: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void filterItems(String query) {
    setState(() {
      filteredItems = items
          .where((item) =>
              item['item_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showItemDialog({Map<String, dynamic>? item}) {
    itemNameController.text = item != null ? item['item_name'] : '';
    itemQuantityController.text =
        item != null ? item['quantity'].toString() : '';
    maxQuantityController.text =
        item != null ? item['max_quantity'].toString() : '';
    editingItemId = item != null ? item['item_id'] : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            item == null ? 'Add Item' : 'Edit Item',
            style: TextStyle(
                 color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: itemQuantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.orange),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: maxQuantityController,
                  decoration: InputDecoration(
                    labelText: 'Max Quantity',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.orange),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (itemNameController.text.isNotEmpty &&
                    itemQuantityController.text.isNotEmpty &&
                    maxQuantityController.text.isNotEmpty) {
                  if (editingItemId == null) {
                    await addItem(
                        itemNameController.text,
                        itemQuantityController.text,
                        maxQuantityController.text);
                  } else {
                    await updateItem(
                        itemNameController.text,
                        itemQuantityController.text,
                        maxQuantityController.text);
                  }
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Gray background for search bar
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey[500]!, // Border color
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: TextStyle(color: Colors.grey[700], fontSize: 17),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                filterItems('');
                              });
                            },
                          )
                        : null,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: filterItems,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => showItemDialog(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Add Item',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.add, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(
                    color: Colors.black,
                    width: 1.5,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(1.5),
                  },
                  children: [
                    // Table Header
                     TableRow(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 209, 103),borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Item Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Max Quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),// Table Rows
                    ...filteredItems.map((item) {
                      bool isLowStock = item['quantity'] < item['max_quantity'];
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isLowStock
                              ? const Color.fromARGB(255, 246, 106, 75)
                              : Colors.yellow[50], // Highlight low stock
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              item['item_id'].toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              item['item_name'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              item['quantity'].toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              item['max_quantity'].toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.deepPurpleAccent),
                              onPressed: () => showItemDialog(item: item),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}