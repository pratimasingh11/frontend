import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // For the combo box
  String dropdownValue = 'ASC';

  // Example product data
  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Product A',
      'category': 'Category 1',
      'isAvailable': true
    },
    {
      'id': 2,
      'name': 'Product B',
      'category': 'Category 2',
      'isAvailable': false
    },
  ];

  // Example categories
  final List<String> categories = ['Category 1', 'Category 2', 'Category 3'];

  // Pop-up dialog to Add/Edit a product
  void showProductDialog({Map<String, dynamic>? product}) {
    final TextEditingController nameController = TextEditingController(
      text: product != null ? product['name'] : '',
    );
    final TextEditingController priceController = TextEditingController(
      text: product != null ? product['price']?.toString() : '',
    );
    String selectedCategory =
        product != null ? product['category'] : categories[0];
    bool isAvailable = product != null ? product['isAvailable'] : false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow[50],
          title: Text(
            product == null ? 'Add Product' : 'Edit Product',
            style: const TextStyle(
                color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add functionality for picture upload
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text('Browse Picture'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active',
                      style: TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isAvailable,
                      onChanged: (bool value) {
                        setState(() {
                          isAvailable = value;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () {
                // Add or edit logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
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
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showProductDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search bar and combo box
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: dropdownValue,
                  items: <String>['ASC', 'DESC']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Table Header
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(
                    1), // ID Column1: FlexColumnWidth(2), // Product Name
                2: FlexColumnWidth(2), // Category
                3: FlexColumnWidth(2), // Availability
                4: FlexColumnWidth(2), // Actions
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.yellow[100]),
                  children: [
                    headerCell('ID'),
                    headerCell('Product Name'),
                    headerCell('Category'),
                    headerCell('Is Available'),
                    headerCell('Actions'),
                  ],
                ),
                ...products.map((product) {
                  return TableRow(
                    children: [
                      cell(product['id'].toString()),
                      cell(product['name']),
                      cell(product['category']),
                      cell(product['isAvailable'] ? 'Yes' : 'No'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                showProductDialog(product: product),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for table cells
  Widget headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
