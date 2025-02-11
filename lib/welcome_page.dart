import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'account.dart';
import 'cart_page.dart'; // For CartPage
import 'category_page.dart'; // For CategoryPage
import 'userOffers.dart'; // Import the OffersPage

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String branchName = "Loading...";
  int? branchId;
  int? userId;
  String selectedSection = "home"; // Default to Offers
  Map<int, int> cart = {}; // Define cart as an empty map

  @override
  void initState() {
    super.initState();
    _fetchBranchDetails(); // Correct function name
  }

  Future<void> _fetchBranchDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    final storedBranchId = prefs.getInt('branch_id');
    final storedUserId = prefs.getInt('user_id');

    // Ensure all required data is available
    if (sessionId == null || storedBranchId == null || storedUserId == null) {
      setState(() {
        branchName = "Session expired, please log in again.";
      });
      return;
    }

    print('Stored Branch ID: $storedBranchId');
    print('Stored User ID: $storedUserId');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/minoriiproject/welcomepage.php'),
        headers: {
          'X-Session-ID': sessionId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'branch_id': storedBranchId,
          'user_id': storedUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            branchName = data['branch_name'];
            branchId = storedBranchId;
            userId = storedUserId; // Ensure userId is set
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
    switch (selectedSection) {
      case 'home':
        return branchId != null
            ? UserOffersPage(branchId: branchId!)
            : const Center(child: Text('Error: Branch ID not available'));
      case 'Categories':
        return (branchId != null && userId != null)
            ? CategoryPage(
                loggedInBranchId: branchId!,
                loggedInUserId: userId!,
              )
            : const Center(
                child: Text('Error: Branch ID & userId not available'));
      case 'Cart':
        return branchId != null && userId != null
            ? CartPage(loggedInBranchId: branchId!, loggedInUserId: userId!)
            : const Center(
                child: Text('Error: Branch ID or User ID not available'));
      case 'Account':
        return branchId != null && userId != null
            ? AccountPage(branchId: branchId!, userId: userId!)
            : const Center(
                child: Text('Error: Branch ID or User ID not available'));
      default:
        return branchId != null
            ? UserOffersPage(branchId: branchId!)
            : const Center(child: Text('Error: Branch ID not available'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: const Color(0xFFFFDE21),
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Text(
                  ' $branchName',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Pacifico',
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            elevation: 0,
          ),
        ),
        body: _buildContent(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFFFDE21),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex(),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), // Icon for Offers
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  int _currentIndex() {
    switch (selectedSection) {
      case 'Home':
        return 0;
      case 'Categories':
        return 1;
      case 'Cart':
        return 2;
      case 'Account':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // Offers
        setState(() {
          selectedSection = 'Home';
        });
        break;
      case 1:
        // Navigate to CategoryPage as a separate page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              loggedInBranchId: branchId!,
              loggedInUserId: userId!,
            ),
          ),
        );
        break;
      case 2:
        // Navigate to CartPage as a separate page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(
              loggedInBranchId: branchId!,
              loggedInUserId: userId!,
            ),
          ),
        );
        break;
      case 3:
        // Navigate to AccountPage as a separate page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountPage(
              branchId: branchId!,
              userId: userId!,
            ),
          ),
        );
        break;
    }
  }
}