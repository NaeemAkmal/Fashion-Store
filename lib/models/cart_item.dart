import 'product.dart';

class CartItem {
  final String id;
  final String productId;
  final String userId;
  final String selectedSize;
  final String selectedColor;
  final int quantity;
  final double price;
  final DateTime addedAt;
  final Product? product; // Optional product details

  CartItem({
    required this.id,
    required this.productId,
    required this.userId,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
    required this.price,
    required this.addedAt,
    this.product,
  });

  // Calculate total price for this cart item
  double get totalPrice => price * quantity;

  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      id: data['id'] ?? '',
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      selectedSize: data['selectedSize'] ?? '',
      selectedColor: data['selectedColor'] ?? '',
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0).toDouble(),
      addedAt: DateTime.parse(data['addedAt']),
      product: data['product'] != null 
          ? Product.fromFirestore(Map<String, dynamic>.from(data['product']))
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
      'price': price,
      'addedAt': addedAt.toIso8601String(),
      if (product != null) 'product': product!.toFirestore(),
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? userId,
    String? selectedSize,
    String? selectedColor,
    int? quantity,
    double? price,
    DateTime? addedAt,
    Product? product,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      addedAt: addedAt ?? this.addedAt,
      product: product ?? this.product,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.productId == productId &&
        other.selectedSize == selectedSize &&
        other.selectedColor == selectedColor;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        selectedSize.hashCode ^
        selectedColor.hashCode;
  }
}
