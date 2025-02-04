import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ProductsPage extends StatefulWidget {
  final int loggedInBranchId;

  const ProductsPage({Key? key, required this.loggedInBranchId}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late int branchId;
  TextEditingController productController = TextEditingController();
  List<Map<String, dynamic>> products = [];
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
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  items: categories.map<DropdownMenuItem<int>>((category) {
                    return DropdownMenuItem<int>(
                      value: category['category_id'],
                      child: Text(category['category_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                ElevatedButton(
                  onPressed: selectImage,
                  child: const Text('Pick Image from Files'),
                ),
                SwitchListTile(
                  title: const Text('Available'),
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() => isAvailable = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newProduct = {
                  'product_name': nameController.text,
                  'product_price':
                      double.tryParse(priceController.text) ?? 0.0,
                  'category_id': selectedCategoryId,
                  'is_available': isAvailable,
                };
                saveProduct(newProduct);
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
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showProductDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2)
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.yellow[100]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('ID',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Product Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Actions',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    ...products.map((product) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product['product_id'].toString(),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product['product_name'],
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () =>
                                      showProductDialog(product: product),
                                ),
                              ],
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