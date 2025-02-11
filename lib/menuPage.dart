import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'cart_page.dart';
import 'providers/cart_provider.dart';
import 'RatingPage.dart'; // Ensure this file exists for the rating feature

class MenuPage extends StatefulWidget {
  final int categoryId;
  final int loggedInBranchId;
  final int loggedInUserId;
  final String categoryName;

  const MenuPage({
    super.key,
    required this.categoryId,
    required this.loggedInBranchId,
    required this.loggedInUserId,
    required this.categoryName,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<dynamic>> products;
  String searchQuery = '';
  String sortBy = '';
  Timer? _ratingTimer;
  final bool _showRatingPrompt = false;

  // Track quantities for each product locally
  late Map<int, int> _productQuantities;

  @override
  void initState() {
    super.initState();
    products = fetchProducts();
    _startRatingTimer();
    _checkRatingPrompt();
    _productQuantities = {};
  }

  @override
  void dispose() {
    _ratingTimer?.cancel();
    super.dispose();
  }

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2/minoriiproject/menuPage.php?category_id=${widget.categoryId}&branch_id=${widget.loggedInBranchId}&user_id=${widget.loggedInUserId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['products'];
        } else {
          throw Exception('No products found');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  void _startRatingTimer() {
    print("Starting rating timer...");
    _ratingTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      print("Checking rating prompt...");
      final shouldPrompt = await _checkRatingPrompt();
      if (shouldPrompt) {
        print("Showing rating dialog...");
        _showRatingDialog();
      }
    });
  }

  Future<bool> _checkRatingPrompt() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2/minoriiproject/checkRatingPrompt.php?user_id=${widget.loggedInUserId}'),
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['prompt_rating'] ?? false;
      } else {
        print("Failed to check rating prompt: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error checking rating prompt: $e");
      return false;
    }
  }

  void _showRatingDialog() {
    print("Showing rating dialog...");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rate Your Order"),
        content: const Text("How would you rate your recent order?"),
        actions: [
          TextButton(
            onPressed: () {
              print("Rating dialog canceled");
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              print("Navigating to RatingPage...");
              Navigator.pop(context);
              _navigateToRatingPage();
            },
            child: const Text("Rate Now"),
          ),
        ],
      ),
    );
  }

  void _navigateToRatingPage() {
    print("Navigating to RatingPage...");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingPage(
          loggedInUserId: widget.loggedInUserId,
        ),
      ),
    );
  }

  List<dynamic> filterProducts(List<dynamic> products, String query) {
    return products.where((product) {
      final productName = product['product_name'].toString().toLowerCase();
      return productName.contains(query.toLowerCase());
    }).toList();
  }

  List<dynamic> sortProducts(List<dynamic> products, String sortBy) {
    switch (sortBy) {
      case 'Price':
        products.sort((a, b) {
          final priceA = double.tryParse(a['product_price'].toString()) ?? 0.0;
          final priceB = double.tryParse(b['product_price'].toString()) ?? 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'Alphabetical':
        products.sort((a, b) => a['product_name'].compareTo(b['product_name']));
        break;
      case 'Rating':
        products.sort((a, b) =>
            (b['average_rating'] ?? 0.0).compareTo(a['average_rating'] ?? 0.0));
        break;
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 253, 228, 6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 25),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 252, 248, 211),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, size: 24),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),

              // Filters Section
              const Padding(
                padding: EdgeInsets.only(left: 30, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['Price', 'Alphabetical', 'Rating']
                      .map((filter) => FilterChip(
                          label: Text(filter,
                              style: const TextStyle(fontSize: 16)),
                          selected: sortBy == filter,
                          onSelected: (bool selected) {
                            setState(() {
                              sortBy = selected ? filter : '';
                            });
                          },
                          backgroundColor:
                              const Color.fromARGB(255, 253, 228, 6),
                          selectedColor: Colors.orange,
                          labelStyle: TextStyle(
                            color:
                                sortBy == filter ? Colors.white : Colors.black,
                          )))
                      .toList(),
                ),
              ),

              // Product List
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: products,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products found'));
                    } else {
                      List<dynamic> filteredProducts =
                          filterProducts(snapshot.data!, searchQuery);
                      if (sortBy.isNotEmpty) {
                        filteredProducts =
                            sortProducts(filteredProducts, sortBy);
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: buildProductCard(product),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          // Bottom Cart Summary
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                if (cartProvider.cartItems.isEmpty) {
                  return const SizedBox();
                }
                final lastItem = cartProvider.cartItems.values.last;
                int quantity =
                    int.tryParse(lastItem['quantity'].toString()) ?? 1;
                String priceText = lastItem['price'].toString();

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              lastItem['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image,
                                      size: 60, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lastItem['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Rs. $priceText",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                onPressed: () {
                                  context.read<CartProvider>().updateQuantity(
                                      lastItem['product_id'], -1);
                                },
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$quantity',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                onPressed: () {context.read<CartProvider>().updateQuantity(
                                      lastItem['product_id'], 1);
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartPage(
                                    loggedInBranchId: widget.loggedInBranchId,
                                    loggedInUserId: widget.loggedInUserId,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Add to Cart",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    final int productId = product['product_id'];
    final double productRating = product['average_rating'] ?? 0.0;

    // Initialize quantity for the product if not already set
    _productQuantities[productId] ??= 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['image_url'],
                width: 100,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 65,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 22),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['product_name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),

                  // Product Price
                  Text(
                    'Rs. ${product['product_price']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Product Rating
                  Row(
                    children: [
                      const Text(
                        'Rating: ',
                        style: TextStyle(fontSize: 14),
                      ),
                      for (int i = 0; i < 5; i++)
                        Icon(
                          i < productRating ? Icons.star : Icons.star_border,
                          color: const Color.fromARGB(255, 255, 187, 0),
                          size: 20,
                        ),
                      Text(
                        '($productRating)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Quantity Controls and Add to Cart Button
                  Row(
                    children: [
                      const SizedBox(width: 45),
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.black,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_productQuantities[productId]! > 0) {
                              _productQuantities[productId] =
                                  _productQuantities[productId]! - 1;
                            }
                          });
                        },
                      ),
                      // const SizedBox(width: 5),
                      Text(
                        '${_productQuantities[productId]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _productQuantities[productId] =
                                _productQuantities[productId]! + 1;
                          });
                        },
                      ),
                      // const SizedBox(width: 4),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.add_shopping_cart,
                          color: _productQuantities[productId]! > 0
                              ? Colors.green
                              : Colors.grey,
                          size: 24,
                        ),
                        onPressed: _productQuantities[productId]! > 0
                            ? () {
                                context.read<CartProvider>().addToCart({
                                  'product_id': productId,
                                  'name': product['product_name'],
                                  'price': product['product_price'],
                                  'quantity': _productQuantities[productId],
                                  'image': product['image_url'],
                                });
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   // SnackBar(
                                //   //   content: Text(
                                //   //       '${product['product_name']} added to cart!'),
                                //   // ),
                                // );
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}