import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminSellersSection extends StatefulWidget {
  final int? selectedBranchId;

  const AdminSellersSection(this.selectedBranchId, {super.key});

  @override
  _SellersSectionState createState() => _SellersSectionState();
}

class _SellersSectionState extends State<AdminSellersSection> {
  bool isLoading = true;
  List sellers = [];
  List filteredSellers = [];
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
      await fetchSellers();
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

    print("Admin Sellers Loaded Session ID: $sessionId");
  }

  Future<void> fetchSellers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString("session_id");
    int? branchId = prefs.getInt("branch_id");

    const String endpoint =
        'http://localhost/minoriiproject/admin_fetchsellers.php';

    try {
      final response = await http.get(
        Uri.parse("$endpoint?session_id=$sessionId&branch_id=$branchId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          List<dynamic> fetchedSellers = responseData['sellers'];

          List<Map<String, dynamic>> updatedSellers = [];
          for (var seller in fetchedSellers) {
            String savedStatus =
                prefs.getString('seller_status_${seller['user_id']}') ??
                    seller['approval_status'] ??
                    'pending';

            updatedSellers.add({
              'user_id': seller['user_id'],
              'email': seller['email'] ?? '',
              'branch_id': seller['branch_id'],
              'branch_name': seller['branch_name'],
              'approval_status': savedStatus,
            });
          }

          setState(() {
            sellers = updatedSellers;
            filteredSellers = List.from(sellers);
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

  void filterSellers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSellers = sellers;
      } else {
        filteredSellers = sellers
            .where((seller) => (seller['email'] ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> updateSellerStatus(int userId, String action) async {
    final response = await http.post(
      Uri.parse('http://localhost/minoriiproject/admin_updatesellerstatus.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'user_id': userId,
        'action': action,
      }),
    );

    print('Response Body: ${response.body}'); // Log the response for debugging

    try {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        // Get the updated status from the response
        String updatedStatus = responseData['status'] ?? 'pending';

        // Update the seller's status in the local state
        setState(() {
          for (var seller in sellers) {
            if (seller['user_id'] == userId) {
              seller['approval_status'] = updatedStatus; // Update the status
            }
          }
          // Refresh the filtered sellers list
          filteredSellers = List.from(sellers);
        });

        showError('Seller status updated successfully.');
      } else {
        showError(responseData['message']);
      }
    } catch (e) {
      print("Error decoding JSON: $e");
      showError('Invalid response from server.');
    }
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget buildSellersTable() {
    return Expanded(
      child: filteredSellers.isEmpty
          ? const Center(child: Text("No sellers found"))
          : DataTable(
              headingRowHeight: 56.0,
              dataRowHeight: 60.0,
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
                DataColumn(
                    label: Text("Action",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filteredSellers.map((seller) {
                return DataRow(cells: [
                  DataCell(Text(seller['user_id'].toString())),
                  DataCell(Text(seller['email'] ?? 'No email')),
                  DataCell(Text(seller['branch_id']?.toString() ?? 'No ID')),
                  DataCell(Text(seller['branch_name'] ?? 'No branch')),
                  DataCell(
                    Row(
                      children: [
                        // Display the correct status based on the approval status
                        if (seller['approval_status'] == 'approved')
                          const Text('Active')
                        else if (seller['approval_status'] == 'rejected')
                          const Text('Inactive')
                        else if (seller['approval_status'] == 'pending') ...[
                          const Text('Pending'),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: () {
                              updateSellerStatus(seller['user_id'], 'approve');
                            },
                            child: const Text('Approve'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              updateSellerStatus(seller['user_id'], 'reject');
                            },
                            child: const Text('Reject'),
                          ),
                        ],
                      ],
                    ),
                  ),
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
            onChanged: filterSellers,
            decoration: InputDecoration(
              hintText: "Search Sellers...",
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
            : buildSellersTable(),
      ],
    );
  }
}