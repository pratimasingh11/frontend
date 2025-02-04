import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'menuPage.dart'; // Import MenuPage

class CategoryPage extends StatefulWidget {
  final int loggedInBranchId;
  final int loggedInUserId;

  const CategoryPage(
      {super.key,
      required this.loggedInBranchId,
      required this.loggedInUserId});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<dynamic>> categories;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    categories = fetchCategories();
  }

  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2/minoriiproject/categories.php?branch_id=${widget.loggedInBranchId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['categories'];
        } else {
          throw Exception('No categories found');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: const Color(0xFFFFDE21),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: handleSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Categories',
                hintStyle: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  color: Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No categories found',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  );
                } else {
                  final filteredCategories = snapshot.data!.where((category) {
                    final name =
                        category['category_name'].toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    padding: const EdgeInsets.all(16),
                    childAspectRatio: 0.85,
                    children: filteredCategories
                        .map((category) => buildCategoryCard(
                              context,
                              category['category_name'],
                              category['image_path'],
                              category['category_id'] ?? 0,
                            ))
                        .toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCard(
      BuildContext context, String title, String imagePath, int categoryId) {
    return GestureDetector(
      onTap: () {
        if (categoryId != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuPage(
                categoryId: categoryId,
                loggedInBranchId: widget.loggedInBranchId,
                loggedInUserId: widget.loggedInUserId,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFDE21),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}