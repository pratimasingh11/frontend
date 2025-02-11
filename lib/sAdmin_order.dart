import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrdersSection extends StatefulWidget {
  final int? selectedBranchId;

  const OrdersSection(this.selectedBranchId, {super.key});

  @override
  _OrdersSectionState createState() => _OrdersSectionState();
}

class _OrdersSectionState extends State<OrdersSection> {
  bool isLoading = false;
  List orders = [];
  List filteredOrders = [];
  List branches = [];
  int? selectedBranchId;

  @override
  void initState() {
    super.initState();
    selectedBranchId = widget.selectedBranchId;
    fetchBranches();
    fetchOrders(selectedBranchId);
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

  Future<void> fetchOrders(int? branchId) async {
    setState(() {
      isLoading = true;
    });

    final endpoint = branchId != null
        ? 'http://localhost/minoriiproject/sAdmin_fetchorders.php?branch_id=$branchId'
        : 'http://localhost/minoriiproject/sAdmin_fetchorders.php';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          filteredOrders = orders;
        });
      } else {
        showError("Failed to fetch orders");
      }
    } catch (e) {
      showError("Error fetching orders: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterOrders(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredOrders = orders;
      } else {
        filteredOrders = orders
            .where((order) =>
                (order['email'] ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (order['product_name'] ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase()))
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
            // All Orders Filter Button
            FilterChip(
              label: Text(
                'All Orders',
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
                fetchOrders(null);
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
                    fetchOrders(selectedBranchId);
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

  Widget buildOrdersTable() {
    return Expanded(
      child: filteredOrders.isEmpty
          ? const Center(child: Text("No orders found"))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 56.0,
                dataRowHeight: 60.0,
                border: TableBorder.all(color: Colors.black, width: 1),
                headingRowColor:
                    WidgetStateColor.resolveWith((states) => Colors.yellow),
                columns: const [
                  DataColumn(
                      label: Text("Order ID",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("User ID",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Email",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Branch Name",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Product ID",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Product Name",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Category",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Quantity",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Price",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Total Amount",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Created At",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  // Add Branch Name column
                ],
                rows: filteredOrders.map((order) {
                  return DataRow(cells: [
                    DataCell(Text(order['order_id'].toString())),
                    DataCell(Text(order['user_id'].toString())),
                    DataCell(Text(order['email'] ?? 'No email')),
                    DataCell(Text(order['branch_name'] ?? 'No branch')),
                    DataCell(Text(order['product_id'].toString())),
                    DataCell(Text(order['product_name'] ?? 'No product name')),
                    DataCell(Text(order['category_name'] ?? 'No category')),
                    DataCell(Text(order['quantity'].toString())),
                    DataCell(Text(order['price'].toString())),
                    DataCell(Text(order['total_amount'].toString())),
                    DataCell(Text(order['created_at'] ?? 'No date')),
                    // Add Branch Name cell
                  ]);
                }).toList(),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            onChanged: filterOrders,
            decoration: InputDecoration(
              hintText: "Search Orders...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.yellow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildBranchButtons(),
        const SizedBox(height: 16),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : buildOrdersTable(),
      ],
    );
  }
}