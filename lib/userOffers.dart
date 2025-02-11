import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserOffersPage extends StatefulWidget {
  final int branchId;

  const UserOffersPage({super.key, required this.branchId});

  @override
  _UserOffersPageState createState() => _UserOffersPageState();
}

class _UserOffersPageState extends State<UserOffersPage> {
  List<Map<String, dynamic>> offers = [];
  List<Map<String, dynamic>> popularItems = [
    {'image_url': 'assets/burger.jpg', 'product_name': 'Burger'},
    {'image_url': 'assets/pizza.jpg', 'product_name': 'Pizza'},
    {'image_url': 'assets/momo.jpg', 'product_name': 'Momo'},
    {'image_url': 'assets/chowmen.jpg', 'product_name': 'Chowmein'},
  ];

  List<Map<String, dynamic>> todaysSpecial = [
    {
      'image_url': 'assets/butter_chicken.jpg',
      'dish_name': 'Butter Chicken',
      'description': 'Creamy and flavorful Indian classic.',
    },
    {
      'image_url': 'assets/chicken wonton soup.jpg',
      'dish_name': 'Chicken Wonton Soup',
      'description': 'Steamed dumplings with spicy sauce.',
    },
    {
      'image_url': 'assets/paneer tikka.jpg',
      'dish_name': 'Paneer Tikka',
      'description': 'Grilled cottage cheese with spices.',
    },
    {
      'image_url': 'assets/khana set veg.jpg',
      'dish_name': 'Khana Set',
      'description': 'Authentic Nepali meal set.',
    },
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchOffers();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchOffers() async {
    final url = Uri.parse(
        'http://10.0.2.2/minoriiproject/user_offers.php?branch_id=${widget.branchId}');
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

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentPage < offers.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startAutoSlide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (offers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Text(
                  "Offers",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (offers.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index % offers.length];
                    return Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        image: DecorationImage(
                          image: NetworkImage(offer['image_url']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          offer['offer_name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            _buildSectionTitle("Popular Items"),
            _buildHorizontalList(popularItems),
            _buildSectionTitle("Today's Special"),
            _buildHorizontalList(todaysSpecial, isSpecial: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.orange[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHorizontalList(List<Map<String, dynamic>> items,
      {bool isSpecial = false}) {
    return SizedBox(
      height: 180, // Adjusted height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16.0)),
                  child: Image.asset(
                    item['image_url'],
                    height: 100,
                    width: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 160,
                        color: Colors.grey,
                        child: const Icon(Icons.image_not_supported, size: 40),);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    item[isSpecial ? 'dish_name' : 'product_name'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}