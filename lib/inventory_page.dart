import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // Removes the debug banner
    home: InventoryPage(),
  ));
}

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> items = [
    {'name': 'Cheese', 'quantity': '2 kg'},
    {'name': 'Tomato Sauce', 'quantity': '1 liter'},
    {'name': 'Pizza Dough', 'quantity': '5 pieces'},
    {'name': 'Pasta', 'quantity': '2 kg'},
    {'name': 'Alfredo Sauce', 'quantity': '1 liter'},
    {'name': 'Bell Peppers', 'quantity': '1 kg'},
    {'name': 'Burger Buns', 'quantity': '10 pieces'},
    {'name': 'Veg Patties', 'quantity': '10 pieces'},
    {'name': 'Lettuce', 'quantity': '500 g'},
  ];

  late List<Map<String, dynamic>> filteredItems;

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(items);
  }

  void searchItem(String query) {
    setState(() {
      filteredItems = query.isEmpty
          ? List.from(items)
          : items
              .where((item) =>
                  item['name'].toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void addItem() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final quantityController = TextEditingController();

        return AlertDialog(
          title: const Text('Add New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(hintText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  setState(() {
                    items.add({
                      'name': nameController.text,
                      'quantity': quantityController.text,
                    });
                    filteredItems = List.from(items);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void editItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController =
            TextEditingController(text: filteredItems[index]['name']);
        final quantityController =
            TextEditingController(text: filteredItems[index]['quantity']);

        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(hintText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  setState(() {
                    final itemIndex = items.indexOf(filteredItems[index]);
                    items[itemIndex] = {
                      'name': nameController.text,
                      'quantity': quantityController.text,
                    };
                    filteredItems = List.from(items);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteItem(int index) {
    setState(() {
      final itemIndex = items.indexOf(filteredItems[index]);
      items.removeAt(itemIndex);
      filteredItems = List.from(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock',
          style: TextStyle(
            fontSize: 32, // Increased font size for Stock title
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              size: 42, // Increased search icon size
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: InventorySearchDelegate(items, searchItem),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.yellow.shade200, // Matching yellow color for items
                    child: ListTile(
                      title: Text(
                        filteredItems[index]['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increased font size for item name
                        ),
                      ),
                      subtitle: Text(
                        'Quantity: ${filteredItems[index]['quantity']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Increased font size for quantity
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editItem(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ElevatedButton(
                onPressed: addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 16,horizontal:25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded button edges
                  ),
                  elevation: 10, // Added shadow to the button
                ),
                child: const Text(
                  'Add New Item',
                  style: TextStyle(
                    fontSize: 20, // Adjusted font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventorySearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> items;
  final Function(String) searchCallback;

  InventorySearchDelegate(this.items, this.searchCallback);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          searchCallback(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items
        .where((item) =>
            item['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]['name']),
          subtitle: Text('Quantity: ${results[index]['quantity']}'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items
        .where((item) =>
            item['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]['name']),
          subtitle: Text('Quantity: ${suggestions[index]['quantity']}'),
          onTap: () {
            query = suggestions[index]['name'];
            showResults(context);
          },
        );
      },
    );
  }
}
