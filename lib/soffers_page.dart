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
  List<Map<String, dynamic>> offers = [];
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
    request.fields['edit_offers'] = '1'; // Corrected key for editing
    request.fields['offers_id'] = offerId.toString(); // Correct field name
} else {
    request.fields['add_offers'] = '1'; // Corrected key for adding
}
request.fields['offer_name'] = name; // Correct field name
 // Match PHP field name

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
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: offersController,
                decoration: InputDecoration(
                  labelText: 'Offer Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectImage,
                child: const Text('Pick Image from Files'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Save'),
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
        title: const Text('Offers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showOfferDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.yellow[100]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'ID',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Offer Name',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ...offers.map((offer) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(offer['offer_id'].toString(),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(offer['offer_name'], textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => showOfferDialog(offer: offer),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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
