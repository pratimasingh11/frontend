import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ProductsPage extends StatefulWidget {
  final int loggedInBranchId;

  const ProductsPage({super.key, required this.loggedInBranchId});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late int branchId;
  TextEditingController productController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> categories = [];
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  int? _editingProductId;

  @override
  void initState() {
    super.initState();
    branchId = widget.loggedInBranchId;
    fetchProducts();
    fetchCategories();
  }

Future<void> fetchProducts() async {
  final response = await http.get(Uri.parse(
      'http://localhost/minoriiproject/sproducts.php?action=fetch_products&branch_id=${widget.loggedInBranchId}'));
  if (response.statusCode == 200) {
    setState(() {
      products = List<Map<String, dynamic>>.from(
          json.decode(response.body)['products']);
      filteredProducts = List.from(products);
    });
  } else {
    print('Failed to fetch products');
  }
}

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse(
        'http://localhost/minoriiproject/sproducts.php?action=fetch_categories&branch_id=${widget.loggedInBranchId}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categories = List<Map<String, dynamic>>.from(data['categories']);
      });
    } else {
      print('Failed to fetch categories');
    }
  }

  Future<void> saveProduct(Map<String, dynamic> product) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://localhost/minoriiproject/sproducts.php?action=${_editingProductId == null ? 'add_product' : 'edit_product'}'),
      );
      request.fields['product_name'] = product['product_name'];
      request.fields['product_price'] = product['product_price'].toString();
      request.fields['category_id'] = product['category_id'].toString();
      request.fields['branch_id'] = widget.loggedInBranchId.toString();
      request.fields['is_available'] = product['is_available'] ? '1' : '0';

      if (_selectedImageBytes != null && _selectedImageName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image_path',
          _selectedImageBytes!,
          filename: _selectedImageName!,
        ));
      }
      if (_editingProductId != null) {
        request.fields['product_id'] = _editingProductId.toString();
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final respData = jsonDecode(respStr);

        if (respData['success'] == true) {
          fetchProducts();
          Navigator.pop(context);
        } else {
          print('Error: ${respData['message']}');
        }
      } else {
        print('Failed to save product');
      }
    } catch (e) {
      print('Error saving product: $e');
    }
  }

  void selectImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _selectedImageBytes = result.files.first.bytes;
          _selectedImageName = result.files.first.name;
        });
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  void showProductDialog({Map<String, dynamic>? product}) {
    _selectedImageBytes = null;
    _selectedImageName = null;
    final nameController =
        TextEditingController(text: product?['product_name']);
    final priceController =
        TextEditingController(text: product?['product_price']?.toString());
    int selectedCategoryId = product?['category_id'] ??
        (categories.isNotEmpty ? categories[0]['category_id'] : 0);
    bool isAvailable = product == null ? true : product['is_available'] == 1;

    _editingProductId = product?['product_id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            product == null ? 'Add Product' : 'Edit Product',
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
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(color: Colors.orange[800]),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 252, 115, 4)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.orange[800]),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 236, 110, 7)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  items: categories.map<DropdownMenuItem<int>>((category) {
                    return DropdownMenuItem<int>(
                      value: category['category_id'],
                      child: Text(
                        category['category_name'],
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.orange[800]),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 245, 115, 8)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedImageBytes != null)
                  Column(
                    children: [
                      Image.memory(
                        _selectedImageBytes!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedImageBytes = null;
                            _selectedImageName = null;
                          });
                        },
                        child: const Text(
                          'Remove Image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ElevatedButton(
                  onPressed: selectImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pick Image from Files',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    'Available',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() => isAvailable = value);
                  },
                  activeColor: Colors.orange[800],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newProduct = {
                  'product_name': nameController.text,
                  'product_price': double.tryParse(priceController.text) ?? 0.0,
                  'category_id': selectedCategoryId,
                  'is_available': isAvailable,
                };
                saveProduct(newProduct);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
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

  void filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((product) => product['product_name']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
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
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: Colors.grey[700], fontSize: 17),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                filterProducts('');
                              });
                            },
                          )
                        : null,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: filterProducts,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => showProductDialog(),
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
                      'Add Product',
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
                            'Product Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Category',
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
                    ),
                    // Table Rows
                    ...filteredProducts.map((product) {
                      return TableRow(
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              product['product_id'].toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              product['product_name'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Rs.${product['product_price'].toString()}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              product['category_name'] ?? 'N/A',
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
                              onPressed: () =>
                                  showProductDialog(product: product),
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