import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class CategoriesPage extends StatefulWidget {
  final int loggedInBranchId;

  const CategoriesPage({super.key, required this.loggedInBranchId});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late int branchId;
  TextEditingController categoryController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> filteredCategories = [];
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    branchId = widget.loggedInBranchId;
    fetchCategories();
  }

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
            filteredCategories = List.from(categories);
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
        fetchCategories();
      } else {
        print('Failed to save category');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void selectImage() async {
    final result = await FilePicker.platform
        .pickFiles(withData: true, type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes;
        _selectedImageName = result.files.first.name;
      });
    }
  }

  void showCategoryDialog({Map<String, dynamic>? category}) {
    _selectedImageBytes = null;
    _selectedImageName = null;
    categoryController.text = category != null ? category['category_name'] : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            category == null ? 'Add Category' : 'Edit Category',
            style: const TextStyle(
                color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: Colors.orange[800]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Pick Image from Files',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.orange)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void filterCategories(String query) {
    setState(() {
      filteredCategories = categories
          .where((category) => category['category_name']
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
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(color: Colors.grey[700], fontSize: 17),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                filterCategories('');
                              });
                            },
                          )
                        : null,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: filterCategories,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => showCategoryDialog(),
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
                      'Add Category',
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
                    2: FlexColumnWidth(1.5),
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
                            'Category Name',
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
                    ...filteredCategories.map((category) {
                      return TableRow(
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              category['category_id'].toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              category['category_name'],
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
                                  showCategoryDialog(category: category),
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