class CartItem {
  final int id;
  final int userId;
  final int productId;
  final String productName;
  final double productPrice;
  int quantity;
  final String addedAt;

  // Constructor to create CartItem object
  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.addedAt,
  });

  // Convert JSON to CartItem object
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      productPrice: json['product_price'],
      quantity: json['quantity'],
      addedAt: json['added_at'],
    );
  }

  // Convert CartItem object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'added_at': addedAt,
    };
  }
}
