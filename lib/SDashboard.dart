import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'scategories_page.dart'; // Import CategoriesPage
import 'sinventory_page.dart';
import 'sproduct_page.dart';

class SellersDashboard extends StatefulWidget {
  final String userEmail;

  const SellersDashboard({Key? key, required this.userEmail}) : super(key: key);

  @override
  _SellersDashboardState createState() => _SellersDashboardState();
}

class _SellersDashboardState extends State<SellersDashboard> {
  String branchName = "Loading...";
  String selectedSection = "Orders";
  bool isSidebarVisible = true; // Track visibility of the sidebar

  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Orders', 'icon': Icons.shopping_cart},
    {'title': 'Categories', 'icon': Icons.category},
    {'title': 'Products', 'icon': Icons.store},
    {'title': 'Bill Lists', 'icon': Icons.receipt_long},
    {'title': 'Reports', 'icon': Icons.analytics},
    {'title': 'Inventory', 'icon': Icons.inventory},
  ];

  @override
  void initState() {
    super.initState();
    _fetchBranchName();
  }

  Future<void> _fetchBranchName() async {
    final url = Uri.parse('http://10.0.2.2/minoriiproject/SDashboard.php');
    final response = await http.post(url, body: {'email': widget.userEmail});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          branchName = data['branch_name'];
        });
      } else {
        setState(() {
          branchName = "Branch not found";
        });
      }
    } else {
      setState(() {
        branchName = "Error fetching branch";
      });
    }
  }

  Widget _buildOrdersTable() {
    final List<Map<String, dynamic>> orders = [
      {
        'id': 1,
        'name': 'Product A',
        'price': 100,
        'quantity': 2,
        'billNo': 101
      },
      {
        'id': 2,
        'name': 'Product B',
        'price': 200,
        'quantity': 1,
        'billNo': 102
      },
      {
        'id': 3,
        'name': 'Product C',
        'price': 150,
        'quantity': 5,
        'billNo': 103
      },
    ];

    return DataTable(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Price')),
        DataColumn(label: Text('Quantity')),
        DataColumn(label: Text('Bill No')),
      ],
      rows: orders
          .map((order) => DataRow(cells: [
                DataCell(Text(order['id'].toString())),
                DataCell(Text(order['name'])),
                DataCell(Text(order['price'].toString())),
                DataCell(Text(order['quantity'].toString())),
                DataCell(Text(order['billNo'].toString())),
              ]))
          .toList(),
    );
  }

  Widget _buildContent() {
    switch (selectedSection) {
      case 'Orders':
        return _buildSectionContent('Orders');
      case 'Categories':
        return CategoriesPage(); // CategoriesPage will be shown when selected
      case 'Products':
        return ProductsPage();
      case 'Bill Lists':
        return _buildSectionContent('Bill Lists');
      case 'Reports':
        return const Center(child: Text('Reports Content Coming Soon'));
      case 'Inventory':
        return InventoryPage();
      default:
        return const Center(child: Text('Select an item from the left menu'));
    }
  }

  Widget _buildSectionContent(String sectionName) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          '$sectionName Content Coming Soon',
          style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.7)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width:
                isSidebarVisible ? 250 : 60, // Adjust width based on visibility
            color: Colors.yellow.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/logo.png'),
                      ),
                      const SizedBox(height: 8),
                      isSidebarVisible
                          ? Text(
                              branchName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Hamburger Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSidebarVisible = !isSidebarVisible;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      isSidebarVisible ? Icons.arrow_forward : Icons.menu,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading:
                            Icon(menuItems[index]['icon'], color: Colors.black),
                        title: isSidebarVisible
                            ? Text(
                                menuItems[index]['title'],
                                style: const TextStyle(color: Colors.black),
                              )
                            : null, // Hide title when sidebar is hidden
                        onTap: () {
                          setState(() {
                            selectedSection = menuItems[index]['title'];
                          });
                        },
                        selected: selectedSection == menuItems[index]['title'],
                        selectedTileColor: Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (isSidebarVisible)
                    const Divider(
                        color: Colors.black), // Add divider between sections
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
