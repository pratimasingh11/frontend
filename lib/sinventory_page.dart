import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryPage extends StatefulWidget {
  final int loggedInBranchId;

  const InventoryPage({Key? key, required this.loggedInBranchId}) : super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> items = [];
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();
  TextEditingController maxQuantityController = TextEditingController();
  int? editingItemId;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final url = 'http://localhost/minoriiproject/sinventory.php';
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
                'quantity': int.parse(item['quantity'].toString()), // Ensure conversion
                'max_quantity': int.parse(item['max_quantity'].toString()), // Ensure conversion
              };
            }).toList();
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

    final url = 'http://localhost/minoriiproject/sinventory.php';
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

  Future<void> updateItem(String name, String quantity, String maxQuantity) async {
    if (int.tryParse(quantity) == null || int.tryParse(maxQuantity) == null) {
      print('Invalid quantity or max quantity');
      return;
    }

    final url = 'http://localhost/minoriiproject/sinventory.php';
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

  void showItemDialog({Map<String, dynamic>? item}) {
    itemNameController.text = item != null ? item['item_name'] : '';
    itemQuantityController.text = item != null ? item['quantity'].toString() : ''; // Convert to String
    maxQuantityController.text = item != null ? item['max_quantity'].toString() : ''; // Convert to String
    editingItemId = item != null ? item['item_id'] : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: itemQuantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: maxQuantityController,
                decoration: const InputDecoration(labelText: 'Max Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (itemNameController.text.isNotEmpty &&
                    itemQuantityController.text.isNotEmpty &&
                    maxQuantityController.text.isNotEmpty) {
                  if (editingItemId == null) {
                    await addItem(itemNameController.text, itemQuantityController.text, maxQuantityController.text);
                  } else {
                    await updateItem(itemNameController.text, itemQuantityController.text, maxQuantityController.text);
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
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
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showItemDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.yellow[100]),
                      children: const [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('ID')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Item Name')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Quantity')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Max Quantity')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Actions')),
                      ],
                    ),
                    ...items.map((item) {
                      bool isLowStock = item['quantity'] < item['max_quantity'];
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isLowStock ? const Color.fromARGB(255, 233, 34, 54) : null,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item['item_id'].toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item['item_name']),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item['quantity'].toString()), // Convert to String
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item['max_quantity'].toString()), // Convert to String
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showItemDialog(item: item),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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
