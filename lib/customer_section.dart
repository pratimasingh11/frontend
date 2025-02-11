import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomersSection extends StatefulWidget {
  final int? selectedBranchId;

  const CustomersSection(this.selectedBranchId, {super.key});

  @override
  _CustomersSectionState createState() => _CustomersSectionState();
}

class _CustomersSectionState extends State<CustomersSection> {
  bool isLoading = false;
  List customers = [];
  List filteredCustomers = [];
  List branches = [];
  int? selectedBranchId;

  @override
  void initState() {
    super.initState();
    selectedBranchId = widget.selectedBranchId;
    fetchBranches();
    fetchCustomers(selectedBranchId);
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
          showError("No branches found or error in data format.");
        }
      } else {
        showError("Failed to fetch branches");
      }
    } catch (e) {
      showError("Error fetching branches: $e");
    }
  }

  Future<void> fetchCustomers(int? branchId) async {
    setState(() {
      isLoading = true;
    });

    final endpoint = branchId != null
        ? 'http://localhost/minoriiproject/sAdmin_fetchcustomers.php?branch_id=$branchId'
        : 'http://localhost/minoriiproject/sAdmin_fetchcustomers.php';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        setState(() {
          customers = jsonDecode(response.body);
          filteredCustomers = customers;
        });
      } else {
        showError("Failed to fetch customers");
      }
    } catch (e) {
      showError("Error fetching customers: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterCustomers(String query) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget buildCustomersTable() {
    return Expanded(
      child: filteredCustomers.isEmpty
          ? const Center(child: Text("No customers found"))
          : DataTable(
              headingRowHeight: 56.0,
              dataRowHeight: 60.0,
              border: TableBorder.all(color: Colors.black, width: 1),
              headingRowColor:
                  WidgetStateColor.resolveWith((states) => Colors.yellow),
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
                borderRadius: BorderRadius.circular(8.0),
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
