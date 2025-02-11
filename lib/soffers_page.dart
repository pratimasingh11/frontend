import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class OffersPage extends StatefulWidget {
  final int loggedInBranchId;

  const OffersPage({Key? key, required this.loggedInBranchId}) : super(key: key);

  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  late int branchId;
  TextEditingController offersController = TextEditingController();
  TextEditingController searchController = TextEditingController(); // Search controller
  List<Map<String, dynamic>> offers = [];
  List<Map<String, dynamic>> filteredOffers = []; // Filtered list for search
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    branchId = widget.loggedInBranchId;
    fetchOffers();
  }

  // Fetch offers from the server
  Future<void> fetchOffers() async {
    final url = Uri.parse(
        'http://localhost/minoriiproject/soffers.php?fetch_offers=1&branch_id=$branchId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            offers = List<Map<String, dynamic>>.from(data['offers']);
            filteredOffers = List.from(offers); // Initialize filtered list
          });
        } else {
          print('Failed to fetch offers: ${data['message']}');
        }
      } else {
        print('Error fetching offers: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Save or edit an offer
  Future<void> saveOffer(String name, {int? offerId}) async {
    final url = Uri.parse('http://localhost/minoriiproject/soffers.php');
    final request = http.MultipartRequest('POST', url);

    if (offerId != null) {
      request.fields['edit_offers'] = '1';
      request.fields['offers_id'] = offerId.toString();
    } else {
      request.fields['add_offers'] = '1';
    }
    request.fields['offer_name'] = name;
    request.fields['branch_id'] = branchId.toString();

    // Add image if selected
    if (_selectedImageBytes != null && _selectedImageName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image_path',
        _selectedImageBytes!,
        filename: _selectedImageName!,
      ));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        fetchOffers(); // Refresh offers list after saving
      } else {
        print('Failed to save offer');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Select an image file
  void selectImage() async {
    final result = await FilePicker.platform.pickFiles(withData: true, type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes;
        _selectedImageName = result.files.first.name;
      });
    }
  }

  // Filter offers by name
  void filterOffers(String query) {
    setState(() {
      filteredOffers = offers
          .where((offer) =>
              offer['offer_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Show offer dialog for adding or editing
  void showOfferDialog({Map<String, dynamic>? offer}) {
    _selectedImageBytes = null;
    _selectedImageName = null;
    offersController.text = offer != null ? offer['offer_name'] : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow[50],
          title: Text(
            offer == null ? 'Add Offer' : 'Edit Offer',
            style: TextStyle(
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: offersController,
                  decoration: InputDecoration(
                    labelText: 'Offer Name',
                    labelStyle: TextStyle(color: Colors.orange[800]),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 252, 115, 4)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: selectImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pick Image from Files',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (offersController.text.isNotEmpty) {
                  await saveOffer(
                    offersController.text,
                    offerId: offer?['offer_id'],
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey[500]!,
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: searchController, // Add controller
                  decoration: InputDecoration(
                    hintText: 'Search offers...',
                    hintStyle: TextStyle(color: Colors.grey[700], fontSize: 17),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                filterOffers('');
                              });
                            },
                          )
                        : null,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: filterOffers, // Call filter function on change
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => showOfferDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Add Offer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.add, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(
                    color: Colors.black,
                    width: 1.5,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(1.5),
                  },
                  children: [
                    // Table Header
                    TableRow(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 209, 103),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Offer Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    // Table Rows
                    ...filteredOffers.map((offer) {
                      return TableRow(
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              offer['offer_id'].toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              offer['offer_name'],
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
                              onPressed: () => showOfferDialog(offer: offer),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}