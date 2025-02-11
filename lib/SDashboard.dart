import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'scategories_page.dart';
import 'sinventory_page.dart';
import 'sproduct_page.dart';
import 'soffers_page.dart';
import 'sreport_page.dart';
import 'sorderbar.dart';
import 'SOrdersPage.dart';
import 'SBillPage.dart';
import 'OrderBillDetailsPage.dart';

class SellersDashboard extends StatefulWidget {
  const SellersDashboard({super.key});

  @override
  _SellersDashboardState createState() => _SellersDashboardState();
}

class _SellersDashboardState extends State<SellersDashboard> {
  String branchName = "Loading...";
  String selectedSection = "Orders";
  bool isSidebarVisible = true;
  int? branchId;

  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Orders', 'icon': Icons.shopping_cart},
    {'title': 'Categories', 'icon': Icons.category},
    {'title': 'Products', 'icon': Icons.store},
    {'title': 'Bill Lists', 'icon': Icons.receipt_long},
    {'title': 'Reports', 'icon': Icons.analytics},
    {'title': 'Inventory', 'icon': Icons.inventory},
    {'title': 'Offers', 'icon': Icons.local_offer},
  ];

  @override
  void initState() {
    super.initState();
    _fetchBranchDetails();
  }

  Future<void> _fetchBranchDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    final storedBranchId = prefs.getInt('branch_id');

    if (sessionId == null || storedBranchId == null) {
      setState(() {
        branchName = "Session expired, please log in again.";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost/minoriiproject/SDashboard.php'),
        headers: {
          'X-Session-ID': sessionId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'branch_id': storedBranchId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            branchName = data['branch_name'];
            branchId = storedBranchId;
          });
        } else {
          setState(() {
            branchName = "Error: ${data['message']}";
          });
        }
      } else {
        setState(() {
          branchName = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        branchName = "Network error, please check your connection.";
      });
    }
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Custom App Bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 244, 183, 16), // Light yellow background
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Selected Section Title
              Text(
                selectedSection,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _buildSelectedContent(),
        ),
      ],
    );
  }

  Widget _buildSelectedContent() {
   switch (selectedSection) {
    case 'Orders':
      return branchId != null
          ? SOrdersPage(loggedInBranchId: branchId!)
          : const Center(child: Text('Error: Branch ID not available'));
    case 'Categories':
      return branchId != null
          ? CategoriesPage(loggedInBranchId: branchId!)
          : const Center(child: Text('Error: Branch ID not available'));
    case 'Products':
      return branchId != null
          ? ProductsPage(loggedInBranchId: branchId!)
          : const Center(child: Text('Error: Branch ID not available'));
          case 'Bill Lists':
      return branchId != null
          ?  SBillPage(loggedInBranchId: branchId!)
          : const Center(child: Text('Error: Branch ID not available'));
     case 'Reports':
      return branchId != null
          ? SReportPage(loggedInBranchId: branchId!)
          : const Center(child: Text('Error: Branch ID not available'));
    case 'Inventory':
      return branchId != null
          ? InventoryPage(loggedInBranchId: branchId!)
          : const Center(child: Text('Error: Branch ID not available'));
    case 'Offers': 
      return branchId != null
          ? OffersPage(loggedInBranchId: branchId!)
          : const Center(child: Text('Error: Branch ID not available'));
    default:
      return const Center(child: Text('Select an item from the menu'));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSidebarVisible ? 250 : 80,
            decoration: BoxDecoration(
              color:  const Color.fromARGB(255, 244, 183, 16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo and Branch Name
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/logo.png'),
                      ),
                      if (isSidebarVisible && branchName != "Loading...")
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            branchName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Toggle Sidebar Button
                ListTile(
                  leading: const Icon(Icons.menu, color: Colors.black),
                  title: isSidebarVisible
                      ? const Text(
                          'Dashboard',
                          style: TextStyle(color: Colors.black),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      isSidebarVisible = !isSidebarVisible;
                    });
                  },
                ),
                const Divider(color: Colors.white54),
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          menuItems[index]['icon'],
                          color: selectedSection == menuItems[index]['title']
                              ? Colors.orange[800]
                              : Colors.black,
                        ),
                        title: isSidebarVisible
                            ? Text(
                                menuItems[index]['title'],
                                style: TextStyle(
                                  color: selectedSection ==
                                          menuItems[index]['title']
                                      ? Colors.orange[800]
                                      : Colors.black,
                                  fontWeight: selectedSection ==
                                          menuItems[index]['title']
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              )
                            : null,
                        tileColor: selectedSection == menuItems[index]['title']
                            ? const Color.fromARGB(255, 232, 237, 221)
                            : Colors.transparent,
                        onTap: () {
                          setState(() {
                            selectedSection = menuItems[index]['title'];
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(20.0),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }
}