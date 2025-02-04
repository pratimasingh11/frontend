import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class CategoriesPage extends StatefulWidget {
  final int loggedInBranchId;

  const CategoriesPage({Key? key, required this.loggedInBranchId}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late int branchId;
  TextEditingController categoryController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    branchId = widget.loggedInBranchId;
    fetchCategories();
  }

  // Fetch categories from the server
  Future<void> fetchCategories() async {
    final url = Uri.parse(
        'http://localhost/minoriiproject/scategories.php?fetch_categories=1&branch_id=$branchId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['categories']);
          });
        } else {
          print('Failed to fetch categories: ${data['message']}');
        }
      } else {
        print('Error fetching categories: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Save or edit a category
  Future<void> saveCategory(String name, {int? categoryId}) async {
    final url = Uri.parse('http://localhost/minoriiproject/scategories.php');
    final request = http.MultipartRequest('POST', url);

    if (categoryId != null) {
      request.fields['edit_category'] = '1';
      request.fields['category_id'] = categoryId.toString();
    } else {
      request.fields['add_category'] = '1';
    }

    request.fields['category_name'] = name;
    request.fields['branch_id'] = branchId.toString();

    // Add image if one is selected
    if (_selectedImageBytes != null && _selectedImageName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image_path',
        _selectedImageBytes!,
        filename: _selectedImageName!,
      ));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        fetchCategories(); // Refresh category list after saving
      } else {
        print('Failed to save category');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Select an image file
  void selectImage() async {
    final result = await FilePicker.platform.pickFiles(withData: true, type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes;
        _selectedImageName = result.files.first.name;
      });
    }
  }

  // Show category dialog for adding or editing
  void showCategoryDialog({Map<String, dynamic>? category}) {
    _selectedImageBytes = null;
    _selectedImageName = null;
    categoryController.text = category != null ? category['category_name'] : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow[50],
          title: Text(
            category == null ? 'Add Category' : 'Edit Category',
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectImage,
                child: const Text('Pick Image from Files'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.isNotEmpty) {
                  await saveCategory(
                    categoryController.text,
                    categoryId: category?['category_id'],
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showCategoryDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.yellow[100]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'ID',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Category Name',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ...categories.map((category) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(category['category_id'].toString(),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(category['category_name'], textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => showCategoryDialog(category: category),
                                ),
                              ],
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
