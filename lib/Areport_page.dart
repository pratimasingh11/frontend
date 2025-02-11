import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Aorderbar.dart';
import 'Aproductbar.dart';

class SReportPage extends StatefulWidget {
  final int loggedInBranchId;
  const SReportPage({required this.loggedInBranchId, super.key});

  @override
  _SReportPageState createState() => _SReportPageState();
}

class _SReportPageState extends State<SReportPage> {
  String selectedFilter = "Daily"; // Default filter
  String selectedView = "Orders"; // Default view (Orders or Products)
  List<int> ordersData = [];
  List<String> labels = [];
  List<int> productSales = []; // To store total quantity sold per product
  List<String> productLabels = []; // To store product names
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String url =
        "http://localhost/minoriiproject/sales_report.php?branch_id=${widget.loggedInBranchId}&filter=$selectedFilter";

    try {
      print("Fetching data from: $url"); // Debugging: Log the URL
      final response = await http.get(Uri.parse(url));

      // Debugging: Log the response status code and body
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          ordersData =
              data["orders"].map<int>((e) => e["totalOrders"] as int).toList();
          labels =
              data["orders"].map<String>((e) => e["label"].toString()).toList();

          // Extract product sales data
          productSales = data["products"]
              .map<int>((e) => e["totalQuantity"] as int)
              .toList();
          productLabels = data["products"]
              .map<String>((e) => e["product_name"].toString())
              .toList();

          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error fetching data: $e"); // Debugging: Log the error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 243, 220, 161),
              Colors.yellow.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 198, 247, 152),
                                Color.fromARGB(255, 239, 213, 142)
                              ],
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButton<String>(
                              value: selectedFilter,
                              items: ['Daily', 'Weekly', 'Monthly']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedFilter = newValue!;
                                  isLoading = true;
                                  fetchData();
                                });
                              },
                              dropdownColor:
                                  const Color.fromARGB(255, 208, 241, 181),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.black),
                              underline: Container(),
                              isExpanded: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade200,
                                Colors.deepOrange.shade100
                              ],
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButton<String>(
                              value: selectedView,
                              items: ['Orders', 'Products'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedView = newValue!;
                                });
                              },dropdownColor: Colors.orange.shade100,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.black),
                              underline: Container(),
                              isExpanded: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrangeAccent,
                        strokeWidth: 4,
                      ),
                    )
                  : Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: selectedView == "Orders"
                            ? OrdersBarChart(
                                ordersData: ordersData, labels: labels)
                            : ProductSalesChart(
                                productData: productSales,
                                labels: productLabels,
                              ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}