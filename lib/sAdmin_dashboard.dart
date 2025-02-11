import 'package:flutter/material.dart';
import 'package:my_flutter_app/sAdmin_order.dart';
import 'seller_section.dart';
import 'customer_section.dart';
import 'product_section.dart';
import 'admin_section.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  _SuperAdminDashboardState createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  String selectedMenu = "Sellers"; // Default menu option
  int? selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: const Color.fromARGB(255, 225, 233, 199),
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 252, 255, 87),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Easy Meals",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 220, 222, 69),
                  Colors.yellow[100]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Row(
            children: [
              // Sidebar Menu
              Container(
                width: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow[500]!,
                      Colors.yellow[500]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 24.0), // Increased left padding
                      child: Row(
                        children: [
                          Icon(
                            Icons.dashboard,
                            size: 40,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black54),
                    _buildMenuButton("Sellers", Icons.store),
                    _buildMenuButton("Customers", Icons.people),
                    _buildMenuButton("Products", Icons.inventory),
                    _buildMenuButton("Orders", Icons.shopping_cart),
                    // _buildMenuButton("Reports & Analytics", Icons.analytics),
                    _buildMenuButton("Admin", Icons.admin_panel_settings),
                  ],
                ),
              ),
              // Content Area with White Background
              Expanded(
                child: Container(
                  color: Colors.white, // Set background to white
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sidebar Menu Button
  Widget _buildMenuButton(String menu, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedMenu = menu;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 24), // Increased left padding
        decoration: BoxDecoration(
          color: selectedMenu == menu ? Colors.yellow[800] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedMenu == menu ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 12),
            Text(
              menu,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedMenu == menu ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Content for the Selected Menu
  Widget _buildContent() {
    switch (selectedMenu) {
      case "Sellers":
        return SellersSection(selectedBranchId);
      case "Customers":
        return CustomersSection(selectedBranchId);
      case "Products":
        return ProductsSection(selectedBranchId);
      case "Orders":
        return OrdersSection(selectedBranchId);
      // case "Reports & Analytics":
      //   if (selectedBranchId != null) {
      //     return SReportPage(loggedInBranchId: selectedBranchId ?? 0);
      //   } else {
      //     return const Center(child: Text("Please select a branch"));
      //   }

      case "Admin":
        return AdminsSection(selectedBranchId);
      default:
        return const Center(child: Text("Select a menu item"));
    }
  }
}