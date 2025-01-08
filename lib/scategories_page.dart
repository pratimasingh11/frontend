import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON response

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String dropdownValue = 'ASC';
  List<Map<String, dynamic>> categories = [];
  final List<String> assetImages = [
    'assets/indian.jpg',
    'assets/nepali.jpg',
    'assets/italian.jpg',
    'assets/chinese.jpg',
    'assets/sweets.jpg',
    'assets/soft_drinks.jpg',
  ];

  String? _selectedImage;
  TextEditingController categoryController = TextEditingController();

  // Example variable, replace with actual logic to fetch the logged-in user's branch_id
  String loggedInBranchId = '2';  // Assuming branch_id for logged-in user is 2

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Fetch categories from the server
  Future<void> fetchCategories() async {
    final url = 'http://10.0.2.2/minoriiproject/scategories.php?fetch_categories=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['categories']);
          });
        } else {
          print('Failed to fetch categories');
        }
      } else {
        print('Error fetching categories: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Add or edit category in the database
  Future<void> saveCategory(String name, String imagePath, {int? categoryId}) async {
    final url = 'http://10.0.2.2/minoriiproject/scategories.php';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    if (categoryId != null) {
      request.fields['edit_category'] = '1';
      request.fields['category_id'] = categoryId.toString();
    } else {
      request.fields['add_category'] = '1';
    }

    request.fields['category_name'] = name;
    request.fields['branch_id'] = loggedInBranchId; // Pass the logged-in user's branch_id
    request.fields['image_path'] = imagePath;

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        fetchCategories();  // Refresh the list
        print('Category saved successfully');
      } else {
        print('Failed to save category');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Show category dialog for adding or editing
  void showCategoryDialog({Map<String, dynamic>? category}) {
    _selectedImage = category != null ? category['image_path'] : null;
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
                onPressed: () {
                  // Show a dialog to pick an image from the assets
                  showImagePickerDialog();
                },
                child: const Text('Pick Image from Assets'),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null) ...[ 
                Image.asset(_selectedImage!, height: 100),
                const SizedBox(height: 10),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save category if name is not empty and an image is selected
                if (categoryController.text.isNotEmpty && _selectedImage != null) {
                  await saveCategory(categoryController.text, _selectedImage!,
                      categoryId: category != null ? category['category_id'] : null);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show the image picker dialog for assets
  void showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select an Image'),
          content: SingleChildScrollView(
            child: Column(
              children: assetImages.map((imagePath) {
                return ListTile(
                  title: Text(imagePath.split('/').last), // Show file name
                  leading: Image.asset(imagePath, width: 50, height: 50),
                  onTap: () {
                    setState(() {
                      _selectedImage = imagePath;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
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
                  columnWidths: {
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
                            child: Text(category['category_id'].toString(), textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(category['category_name'], textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
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
