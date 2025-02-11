import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminProductsSection extends StatefulWidget {
  final int? selectedBranchId;
  const AdminProductsSection(this.selectedBranchId, {super.key});

  @override
  _AdminProductsSectionState createState() => _AdminProductsSectionState();
}

class _AdminProductsSectionState extends State<AdminProductsSection> {
  bool isLoading = false;
  List products = [];
  List filteredProducts = [];
  int? selectedBranchId;
  String? sessionId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getSessionId();
    if (sessionId != null) {
      fetchProducts();
    } else {
      showError('Session expired. Please log in again.');
    }
  }

  // Fetch sessionId from SharedPreferences
  Future<void> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sessionId = prefs.getString('session_id'); // ✅ Correct key
      selectedBranchId = prefs.getInt('branch_id'); // ✅ Correct key
    });

    if (sessionId == null) {
      showError('Session ID missing. Please log in again.');
      return;
    }

    print("Admin Sellers Loaded Session ID: $sessionId"); // Debugging
  }

  Future<void> fetchProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString("session_id");
    int? branchId = prefs.getInt("branch_id");

    const String endpoint =
        'http://localhost/minoriiproject/admin_fetchproducts.php';

    try {
      final response = await http.get(
        Uri.parse(
            "$endpoint?session_id=$sessionId&branch_id=$branchId"), // ✅ Pass both session_id & branch_id
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("Session ID Sent: $sessionId");
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // ✅ Debugging

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          setState(() {
            products = responseData['products'];
            filteredProducts = products;
          });
        } else {
          showError(responseData['message']);
        }
      } else {
        showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      showError('An error occurred while fetching sellers.');
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterProducts(String query) {
    print('Filter Query: $query'); // Log the query string
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) => (product['product_name'] ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
      print('Filtered Products: $filteredProducts'); // Log filtered sellers
    });
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget buildProductsTable() {
    return filteredProducts.isEmpty
        ? const Center(child: Text("No products found"))
        : DataTable(
            border: TableBorder.all(color: Colors.black, width: 1),
            headingRowColor: WidgetStateProperty.all(Colors.yellow),
            columns: const [
              DataColumn(
                  label: Text("Product ID",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text("Product Name",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text("Price",
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
                DataCell(
                    Text(product['product_price']?.toString() ?? 'No price')),
                DataCell(Text(product['category_name'] ?? 'No category')),
                DataCell(Text(product['branch_id']?.toString() ?? 'No ID')),
                DataCell(Text(product['branch_name'] ?? 'No branch')),
              ]);
            }).toList(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Products"),
      ),
      body: Column(
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
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SingleChildScrollView(
                    child: buildProductsTable(),
                  ),
                ),
        ],
      ),
    );
  }
}