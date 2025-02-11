import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminOrdersSection extends StatefulWidget {
  final int? selectedBranchId;

  const AdminOrdersSection(this.selectedBranchId, {super.key});

  @override
  _AdminOrdersSectionState createState() => _AdminOrdersSectionState();
}

class _AdminOrdersSectionState extends State<AdminOrdersSection> {
  bool isLoading = false;
  List orders = [];
  List filteredOrders = [];
  int? selectedBranchId;
  String? sessionId;
  String selectedFilter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getSessionId();
    if (sessionId != null) {
      fetchOrders();
    } else {
      showError('Session ID missing. Please log in again.');
    }
  }

  Future<void> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sessionId = prefs.getString('session_id');
      selectedBranchId = prefs.getInt('branch_id');
    });

    if (sessionId == null) {
      showError('Session ID missing. Please log in again.');
      return;
    }

    print("Admin Orders Loaded Session ID: $sessionId");
  }

  Future<void> fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString("session_id");
    int? branchId = prefs.getInt("branch_id");

    const String endpoint =
        'http://localhost/minoriiproject/admin_fetchorders.php';

    try {
      final response = await http.get(
        Uri.parse("$endpoint?session_id=$sessionId&branch_id=$branchId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("Session ID Sent: $sessionId");
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          setState(() {
            orders = responseData['orders'];
            filteredOrders = orders;
          });
        } else {
          showError(responseData['message']);
        }
      } else {
        showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      showError('An error occurred while fetching orders.');
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterOrders(String filter) {
    setState(() {
      selectedFilter = filter;
      DateTime now = DateTime.now();
      switch (filter) {
        case 'Today':
          filteredOrders = orders.where((order) {
            DateTime orderDate = DateTime.parse(order['created_at']);
            return orderDate.year == now.year &&
                orderDate.month == now.month &&
                orderDate.day == now.day;
          }).toList();
          break;
        case 'Week':
          filteredOrders = orders.where((order) {
            DateTime orderDate = DateTime.parse(order['created_at']);
            return orderDate
                .isAfter(now.subtract(Duration(days: now.weekday - 1)));
          }).toList();
          break;
        case 'Month':
          filteredOrders = orders.where((order) {
            DateTime orderDate = DateTime.parse(order['created_at']);
            return orderDate.year == now.year && orderDate.month == now.month;
          }).toList();
          break;
        default:
          filteredOrders = orders;
          break;
      }
    });
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
                headingRowColor: WidgetStateProperty.all(Colors.yellow),
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
                      label: Text("Product ID",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Product Name",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Category",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Qty",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Price",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Total Amount",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Date",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: filteredOrders.map<DataRow>((order) {
                  return DataRow(cells: [
                    DataCell(Text(order['order_id'].toString())),
                    DataCell(Text(order['user_id'].toString())),
                    DataCell(Text(order['email'] ?? 'N/A')),
                    DataCell(Text(order['product_id'].toString())),
                    DataCell(Text(order['product_name'] ?? 'N/A')),
                    DataCell(Text(order['category_name'] ?? 'N/A')),
                    DataCell(Text(order['quantity'].toString())),
                    DataCell(Text(order['price'].toString())),
                    DataCell(Text(order['total_amount'].toString())),
                    DataCell(Text(order['created_at'])),
                  ]);
                }).toList(),
              ),
            ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(onChanged: (query) {
              setState(() {
                if (query.isEmpty) {
                  filteredOrders = orders;
                } else {
                  filteredOrders = orders.where((order) {
                    // Check if the search query matches either order_id or product_name
                    return order['order_id'].toString().contains(query) ||
                        (order['product_name'] != null &&
                            order['product_name']
                                .toLowerCase()
                                .contains(query.toLowerCase()));
                  }).toList();
                }
              });
            },
            decoration: InputDecoration(
              hintText: "Search Orders...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.yellow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
        ),

        // Increased top padding for the filter chips
        Padding(
          padding: const EdgeInsets.only(top: 20.0), // Increased top padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // All Filter Button
              FilterChip(
                label: Text(
                  'All',
                  style: TextStyle(
                    color:
                        selectedFilter == 'All' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor:
                    selectedFilter == 'All' ? Colors.yellow : Colors.grey[200],
                selectedColor: Colors.yellow,
                selected: selectedFilter == 'All',
                onSelected: (bool selected) {
                  filterOrders('All');
                },
                shape:
                    const StadiumBorder(side: BorderSide(color: Colors.yellow)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),

              // Today Filter Button
              FilterChip(
                label: Text(
                  'Today',
                  style: TextStyle(
                    color:
                        selectedFilter == 'Today' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: selectedFilter == 'Today'
                    ? Colors.yellow
                    : Colors.grey[200],
                selectedColor: Colors.yellow,
                selected: selectedFilter == 'Today',
                onSelected: (bool selected) {
                  filterOrders('Today');
                },
                shape:
                    const StadiumBorder(side: BorderSide(color: Colors.yellow)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),

              // Week Filter Button
              FilterChip(
                label: Text(
                  'Week',
                  style: TextStyle(
                    color:
                        selectedFilter == 'Week' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor:
                    selectedFilter == 'Week' ? Colors.yellow : Colors.grey[200],
                selectedColor: Colors.yellow,
                selected: selectedFilter == 'Week',
                onSelected: (bool selected) {
                  filterOrders('Week');
                },
                shape:
                    const StadiumBorder(side: BorderSide(color: Colors.yellow)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),

              // Month Filter Button
              FilterChip(
                label: Text(
                  'Month',
                  style: TextStyle(
                    color:
                        selectedFilter == 'Month' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: selectedFilter == 'Month'
                    ? Colors.yellow
                    : Colors.grey[200],
                selectedColor: Colors.yellow,
                selected: selectedFilter == 'Month',
                onSelected: (bool selected) {
                  filterOrders('Month');
                },
                shape:
                    const StadiumBorder(side: BorderSide(color: Colors.yellow)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ],
          ),
        ),

        // Increased space between filter list and table
        const SizedBox(height: 30), // Increased height for more space

        // Orders Table
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : buildOrdersTable(),
      ],
    );
  }
}