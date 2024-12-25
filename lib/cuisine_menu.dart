// import 'package:flutter/material.dart';

// class CuisineMenu extends StatelessWidget {
//   final String cuisineName;

//   const CuisineMenu({
//     required this.cuisineName,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final menuItems = getMenuItemsForCuisine(cuisineName);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$cuisineName Menu'),
//         backgroundColor: const Color(0xFFFFC400),
//         foregroundColor: Colors.black,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16.0),
//         itemCount: menuItems.length,
//         itemBuilder: (context, index) {
//           final item = menuItems[index];
//           return MenuItemCard(item: item);
//         },
//       ),
//     );
//   }

//   List<Map<String, dynamic>> getMenuItemsForCuisine(String cuisineName) {
//     switch (cuisineName) {
//       case 'Indian':
//         return [
//           {'name': 'Biryani', 'price': 250.0, 'image': 'assets/biryani.jpg'},
//           {
//             'name': 'Butter Chicken',
//             'price': 300.0,
//             'image': 'assets/butter_chicken.jpg'
//           },
//           {'name': 'Dosa', 'price': 100.0, 'image': 'assets/dosa.jpg'},
//         ];
//       case 'Nepali':
//         return [
//           {'name': 'Momo', 'price': 150.0, 'image': 'assets/momo.jpg'},
//           {'name': 'Thukpa', 'price': 180.0, 'image': 'assets/thukpa.jpg'},
//         ];
//       case 'Italian':
//         return [
//           {'name': 'Pizza', 'price': 400.0, 'image': 'assets/pizza.jpg'},
//           {'name': 'Pasta', 'price': 300.0, 'image': 'assets/pasta.jpg'},
//         ];
//       case 'Chinese':
//         return [
//           {'name': 'Noodles', 'price': 200.0, 'image': 'assets/noodles.jpg'},
//           {
//             'name': 'Manchurian',
//             'price': 220.0,
//             'image': 'assets/manchurian.jpg'
//           },
//         ];
//       case 'Soft Drinks':
//         return [
//           {'name': 'Coke', 'price': 50.0, 'image': 'assets/coke.jpg'},
//           {'name': 'Fanta', 'price': 50.0, 'image': 'assets/fanta.jpg'},
//         ];
//       case 'Sweets':
//         return [
//           {
//             'name': 'Gulab Jamun',
//             'price': 80.0,
//             'image': 'assets/gulab_jamun.jpg'
//           },
//           {'name': 'Laddu', 'price': 70.0, 'image': 'assets/laddu.jpg'},
//         ];
//       default:
//         return [];
//     }
//   }
// }

// class MenuItemCard extends StatefulWidget {
//   final Map<String, dynamic> item;

//   const MenuItemCard({required this.item, super.key});

//   @override
//   _MenuItemCardState createState() => _MenuItemCardState();
// }

// class _MenuItemCardState extends State<MenuItemCard> {
//   int quantity = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: const Color.fromARGB(255, 82, 210, 238), // Light shade of yellow
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             // Profile picture
//             Image.asset(
//               widget.item['image'] ?? 'assets/default.jpg',
//               width: 50,
//               height: 50,
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(width: 16), // Spacing between image and text
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.item['name'] ?? 'Unknown Item',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold, // Bold font for menu name
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 4), // Small spacing
//                   Text(
//                     'Price: Rs. ${widget.item['price']?.toStringAsFixed(2) ?? 'N/A'}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold, // Bold font for price
//                       fontSize: 14,
//                       // color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.remove),
//                   onPressed: () {
//                     setState(() {
//                       if (quantity > 0) quantity--;
//                     });
//                   },
//                 ),
//                 Text('$quantity'),
//                 IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: () {
//                     setState(() {
//                       quantity++;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
