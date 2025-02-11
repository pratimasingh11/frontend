import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminsSection extends StatefulWidget {
  final int? selectedBranchId;

  const AdminsSection(this.selectedBranchId, {super.key});

  @override
  _AdminsSectionState createState() => _AdminsSectionState();
}

class _AdminsSectionState extends State<AdminsSection> {
  bool isLoading = false;
  List admins = [];
  List filteredAdmins = [];
  List branches = [];
  int? selectedBranchId;

  @override
  void initState() {
    super.initState();
    selectedBranchId = widget.selectedBranchId;
    fetchBranches();
    fetchAdmins(selectedBranchId);
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

  Future<void> fetchAdmins(int? branchId) async {
    setState(() {
      isLoading = true;
      admins.clear(); // Clear the previous data
      filteredAdmins.clear();
    });

    final endpoint = branchId != null
        ? 'http://localhost/minoriiproject/sAdmin_fetchadmins.php?branch_id=$branchId'
        : 'http://localhost/minoriiproject/sAdmin_fetchadmins.php';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          List newAdmins = data['admins'];

          // Use the status from the database directly
          setState(() {
            admins = newAdmins;
            filteredAdmins = List.from(admins); // Update filteredAdmins
          });
        } else {
          showError("Failed to fetch admins");
        }
      } else {
        showError("Failed to fetch admins");
      }
    } catch (e) {
      showError("Error fetching admins: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterAdmins(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAdmins = admins;
      } else {
        filteredAdmins = admins
            .where((admin) => (admin['email'] ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Update the admin's approval status
  Future<void> updateAdminStatus(int adminId, String action) async {
  setState(() {
    isLoading = true; // Show loading indicator while processing
  });

  final response = await http.post(
    Uri.parse('http://localhost/minoriiproject/sAdmin_updateAdminStatus.php'),
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      'user_id': adminId,
      'action': action,
    }),
  );

  print('Response Body: ${response.body}'); // Log the response for debugging

  try {
    final responseData = json.decode(response.body);
    if (responseData['success']) {
      String updatedStatus = responseData['status'] ?? 'pending';

      // Update the status of the admin in both admins and filteredAdmins
      setState(() {
        for (var admin in admins) {
          if (admin['admin_id'] == adminId) {
            admin['approval_status'] = updatedStatus;
          }
        }

        // Ensure filteredAdmins is also updated
        filteredAdmins = List.from(admins); // Refresh filteredAdmins with updated admins
      });

      showError('Admin status updated successfully.');
    } else {
      showError(responseData['message']);
    }
  } catch (e) {
    print("Error decoding JSON: $e");
    showError('Invalid response from server.');
  }

  setState(() {
    isLoading = false; // Hide loading indicator
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
            FilterChip(
              label: Text(
                'All Admins',
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
                fetchAdmins(null);
              },
              shape:
                  const StadiumBorder(side: BorderSide(color: Colors.yellow)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            const SizedBox(width: 8),
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
                    fetchAdmins(selectedBranchId);
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

  Widget buildAdminsTable() {
    return Expanded(
      child: filteredAdmins.isEmpty
          ? const Center(child: Text("No admins found"))
          : DataTable(headingRowHeight: 56.0,
              dataRowHeight: 60.0,
              border: TableBorder.all(color: Colors.black, width: 1),
              headingRowColor: WidgetStateProperty.all(Colors.yellow),
              columns: const [
                DataColumn(
                    label: Text("Admin ID",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("Full Name",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("Email",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("Contact",
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
              rows: filteredAdmins.map((admin) {
                final approvalStatus = admin['approval_status'] ?? 'pending';
                return DataRow(cells: [
                  DataCell(Text(admin['admin_id'].toString())),
                  DataCell(Text(admin['full_name'] ?? 'No Name')),
                  DataCell(Text(admin['email'] ?? 'No Email')),
                  DataCell(Text(admin['contact'] ?? 'No Contact')),
                  DataCell(Text(admin['branch_id']?.toString() ?? 'No ID')),
                  DataCell(Text(admin['branch_name'] ?? 'No branch')),
                 DataCell(
  Row(
    children: [
      // Show 'Active' or 'Inactive' or 'Pending' based on the approval status
      if (approvalStatus == 'approved')
        const Text('Active', style: TextStyle(color: Colors.green))
      else if (approvalStatus == 'rejected')
        const Text('Inactive', style: TextStyle(color: Colors.red))
      else if (approvalStatus == 'pending') ...[
        const Text('Pending', style: TextStyle(color: Colors.orange)),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            updateAdminStatus(admin['admin_id'], 'approve');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Approve', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            updateAdminStatus(admin['admin_id'], 'reject');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Reject', style: TextStyle(color: Colors.white)),
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
            onChanged: filterAdmins,
            decoration: InputDecoration(
              hintText: "Search Admins...",
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
            : buildAdminsTable(),
      ],
    );
  }
}