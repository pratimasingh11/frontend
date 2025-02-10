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
  const SellersDashboard({Key? key}) : super(key: key);

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

  print("Retrieved session_id: $sessionId");
  print("Retrieved branch_id: $storedBranchId");

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
          'X-Session-ID': sessionId, // Send session ID
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'branch_id': storedBranchId}), // Send branch_id
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            branchName = data['branch_name']; // Update branch name from response
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
      print("Network Error: $e");
      setState(() {
        branchName = "Network error, please check your connection.";
      });
    }
  }

 Widget _buildContent() {
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSidebarVisible ? 250 : 60,
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
                        leading: Icon(menuItems[index]['icon'], color: Colors.black),
                        title: isSidebarVisible
                            ? Text(
                                menuItems[index]['title'],
                                style: const TextStyle(color: Colors.black),
                              )
                            : null,
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
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (isSidebarVisible) const Divider(color: Colors.black),
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
