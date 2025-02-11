import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminCustomersSection extends StatefulWidget {
  final int? selectedBranchId;

  const AdminCustomersSection(this.selectedBranchId, {super.key});

  @override
  _CustomersSectionState createState() => _CustomersSectionState();
}

class _CustomersSectionState extends State<AdminCustomersSection> {
  bool isLoading = false;
  List customers = [];
  List filteredCustomers = [];
  int? selectedBranchId;
  String? sessionId; // Variable to store session ID

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getSessionId(); // ✅ Wait until session ID is loaded
    if (sessionId != null) {
      fetchCustomers(); // ✅ Now fetch sellers
    } else {
      showError('Session ID missing. Please log in again.');
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

    print("Admin Customers Loaded Session ID: $sessionId"); // Debugging
  }

  Future<void> fetchCustomers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString("session_id");
    int? branchId = prefs.getInt("branch_id");

    const String endpoint =
        'http://localhost/minoriiproject/admin_fetchcustomers.php';

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
            customers = responseData['customers'];
            filteredCustomers = customers;
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

  void filterCustomers(String query) {
    print('Filter Query: $query'); // Log the query string
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers
            .where((customer) => (customer['email'] ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
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

  Widget buildCustomersTable() {
    return Expanded(
      child: filteredCustomers.isEmpty
          ? const Center(child: Text("No customers found"))
          : DataTable(
              border: TableBorder.all(color: Colors.black, width: 1),
              headingRowColor: WidgetStateProperty.all(Colors.yellow),
              columns: const [
                DataColumn(
                    label: Text("User ID",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("Email",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("Branch ID",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("Branch Name",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filteredCustomers.map((customer) {
                return DataRow(cells: [
                  DataCell(Text(customer['user_id'].toString())),
                  DataCell(Text(customer['email'] ?? 'No email')),
                  DataCell(Text(customer['branch_id']?.toString() ?? 'No ID')),
                  DataCell(Text(customer['branch_name'] ?? 'No branch')),
                ]);
              }).toList(),
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
            onChanged: filterCustomers,
            decoration: InputDecoration(
              hintText: "Search Customers...",
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
            : buildCustomersTable(),
      ],
    );
  }
}