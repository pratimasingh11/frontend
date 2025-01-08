import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON response

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> items = [];
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();

  String loggedInBranchId = '2';  // Replace with actual logged-in user branch_id
  int? editingItemId;  // To store the ID of the item being edited

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final url = 'http://10.0.2.2/minoriiproject/sinventory.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'fetch_items': '1',
        'branch_id': loggedInBranchId,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            items = List<Map<String, dynamic>>.from(data['items']);
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

  Future<void> addItem(String name, String quantity) async {
    final url = 'http://10.0.2.2/minoriiproject/sinventory.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'add_item': '1',
        'item_name': name,
        'quantity': quantity,
        'branch_id': loggedInBranchId,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          fetchItems(); // Refresh the list after adding an item
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

  Future<void> updateItem(String name, String quantity) async {
    final url = 'http://10.0.2.2/minoriiproject/sinventory.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'update_item': '1',
        'item_id': editingItemId.toString(),
        'item_name': name,
        'quantity': quantity,
        'branch_id': loggedInBranchId,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          fetchItems(); // Refresh the list after updating an item
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
    // If item is provided, it's for editing
    itemNameController.text = item != null ? item['item_name'] : '';
    itemQuantityController.text = item != null ? item['quantity'] : '';
    editingItemId = item != null ? item['item_id'] : null;  // Store the item id for editing

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
                if (itemNameController.text.isNotEmpty && itemQuantityController.text.isNotEmpty) {
                  if (editingItemId == null) {
                    // Add new item if editingItemId is null
                    await addItem(itemNameController.text, itemQuantityController.text);
                  } else {
                    // Update existing item
                    await updateItem(itemNameController.text, itemQuantityController.text);
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
        backgroundColor: Colors.yellow[700], // Set the same color as CategoriesPage
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
                      decoration: BoxDecoration(color: Colors.yellow[100]), // Table header color
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('ID')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Item Name')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Quantity')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Actions')),
                      ],
                    ),
                    ...items.map((item) {
                      return TableRow(
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
                            child: Text(item['quantity']),
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
