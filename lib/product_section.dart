import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductsSection extends StatefulWidget {
  final int? selectedBranchId;

  const ProductsSection(this.selectedBranchId, {super.key});

  @override
  _ProductsSectionState createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  bool isLoading = false;
  List products = [];
  List filteredProducts = [];
  List branches = [];
  int? selectedBranchId;

  @override
  void initState() {
    super.initState();
    selectedBranchId = widget.selectedBranchId;
    fetchBranches();
    fetchProducts(selectedBranchId);
  }

  Future<void> fetchBranches() async {
    const branchesEndpoint =
        'http://localhost/minoriiproject/sAdmin_fetchbranches.php';

    try {
      final response = await http.get(Uri.parse(branchesEndpoint));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true && data['branches'] is List) {
          setState(() {
            branches = data['branches'];
          });
        } else {
          showError(data['message'] ?? "Failed to load branches.");
        }
      } else {
        showError("Error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching branches: $e");
    }
  }

  Future<void> fetchProducts(int? branchId) async {
    setState(() {
      isLoading = true;
    });

    final endpoint = branchId != null
        ? 'http://localhost/minoriiproject/sAdmin_fetchproducts.php?branch_id=$branchId'
        : 'http://localhost/minoriiproject/sAdmin_fetchproducts.php';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          filteredProducts = products;
        });
      } else {
        showError("Failed to fetch products");
      }
    } catch (e) {
      showError("Error fetching products: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) =>
                (product['product_name'] ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (product['category_name'] ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase())) // Filter by category name
            .toList();
      }
    });
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget buildBranchButtons() {
    if (branches.isEmpty) {
      return const Center(child: Text("No branches available"));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // All Sellers Filter Button
            FilterChip(
              label: Text(
                'All Products',
                style: TextStyle(
                  color: selectedBranchId == null ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor:
                  selectedBranchId == null ? Colors.yellow : Colors.grey[200],
              selectedColor: Colors.yellow,
              selected: selectedBranchId == null,
              onSelected: (bool selected) {
                setState(() {
                  selectedBranchId = null;
                });
                fetchProducts(null);
              },
              shape:
                  const StadiumBorder(side: BorderSide(color: Colors.yellow)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            // Space between buttons
            const SizedBox(width: 8),
            // Branch Filter Buttons
            ...branches.map((branch) {
              bool isSelected =
                  selectedBranchId == int.parse(branch['id'].toString());
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(
                    branch['name'] ?? 'Branch',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor:
                      isSelected ? Colors.yellow : Colors.grey[200],
                  selectedColor: Colors.yellow,
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedBranchId = int.parse(branch['id'].toString());
                    });
                    fetchProducts(selectedBranchId);
                  },
                  shape: const StadiumBorder(
                      side: BorderSide(color: Colors.yellow)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildProductsTable() {
    if (filteredProducts.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal, // Allow horizontal scrolling for the table
      child: DataTable(
        headingRowHeight: 56.0, // Optional: Customize header row height
        dataRowHeight: 60.0, // Optional: Customize data row height
        border: TableBorder.all(color: Colors.black, width: 1),
        headingRowColor:
            WidgetStateColor.resolveWith((states) => Colors.yellow),
        columns: const [
          DataColumn(
              label: Text("Product ID",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("Product Name",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("Price", // New column for product price
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("Category",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("Branch ID",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("Branch Name",
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: filteredProducts.map((product) {
          return DataRow(cells: [
            DataCell(Text(product['product_id'].toString())),
            DataCell(Text(product['product_name'] ?? 'No name')),
            DataCell(Text(product['product_price']?.toString() ??
                'N/A')), // Display product price
            DataCell(Text(product['category_name'] ?? 'No category')),
            DataCell(Text(product['branch_id'].toString())),
            DataCell(Text(product['branch_name'] ?? 'No branch')),
          ]);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(
            16.0), // Optional: Add padding for better spacing
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                onChanged: filterProducts,
                decoration: InputDecoration(
                  hintText: "Search Products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.yellow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(
                height: 16), // Adds space between search bar and branch buttons
            buildBranchButtons(),
            const SizedBox(
                height:
                    16), // Adds space between branch buttons and product list
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : buildProductsTable(),
          ],
        ),
      ),
    );
  }
}