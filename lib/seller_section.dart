import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SellersSection extends StatefulWidget {
  final int? selectedBranchId;

  const SellersSection(this.selectedBranchId, {super.key});

  @override
  _SellersSectionState createState() => _SellersSectionState();
}

class _SellersSectionState extends State<SellersSection> {
  bool isLoading = false;
  List sellers = [];
  List filteredSellers = [];
  List branches = [];
  int? selectedBranchId;

  @override
  void initState() {
    super.initState();
    selectedBranchId = widget.selectedBranchId;
    fetchBranches();
    fetchSellers(selectedBranchId);
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
          showError(data['message'] ?? "Failed to load branches.");
        }
      } else {
        showError("Error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching branches: $e");
    }
  }

  Future<void> fetchSellers(int? branchId) async {
    setState(() {
      isLoading = true;
    });

    final endpoint = branchId != null
        ? 'http://localhost/minoriiproject/sAdmin_fetchsellers.php?branch_id=$branchId'
        : 'http://localhost/minoriiproject/sAdmin_fetchsellers.php';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        setState(() {
          sellers = jsonDecode(response.body);
          filteredSellers = sellers;
        });
      } else {
        showError("Failed to fetch sellers");
      }
    } catch (e) {
      showError("Error fetching sellers: $e");
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
                'All Sellers',
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
                fetchSellers(null);
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
                    fetchSellers(selectedBranchId);
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

  Widget buildSellersTable() {
    return Expanded(
      child: filteredSellers.isEmpty
          ? const Center(child: Text("No sellers found"))
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
              rows: filteredSellers.map((seller) {
                return DataRow(cells: [
                  DataCell(Text(seller['user_id'].toString())),
                  DataCell(Text(seller['email'] ?? 'No email')),
                  DataCell(Text(seller['branch_id']?.toString() ?? 'No ID')),
                  DataCell(Text(seller['branch_name'] ?? 'No branch')),
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
        buildBranchButtons(),
        const SizedBox(height: 16),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : buildSellersTable(),
      ],
    );
  }
}
