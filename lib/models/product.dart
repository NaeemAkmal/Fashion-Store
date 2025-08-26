import 'product_review.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String category;
  final String subCategory;
  final String brand;
  final List<String> sizes;
  final List<String> colors;
  final Map<String, dynamic> specifications;
  final double rating;
  final int reviewCount;
  final int stockQuantity;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductReview> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.category,
    required this.subCategory,
    required this.brand,
    required this.sizes,
    required this.colors,
    required this.specifications,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.stockQuantity,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.reviews = const [],
  });

  // Calculate final price with discount
  double get finalPrice => discountPrice ?? price;
  
  // Calculate discount percentage
  double get discountPercentage {
    if (discountPrice != null) {
      return ((price - discountPrice!) / price * 100);
    }
    return 0.0;
  }

  // Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  
  // Get original price (used for showing crossed out price)
  double get originalPrice => hasDiscount ? price : 0.0;

  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discountPrice: data['discountPrice']?.toDouble(),
      images: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      brand: data['brand'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      stockQuantity: data['stockQuantity'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'category': category,
      'subCategory': subCategory,
      'brand': brand,
      'sizes': sizes,
      'colors': colors,
      'specifications': specifications,
      'rating': rating,
      'reviewCount': reviewCount,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? images,
    String? category,
    String? subCategory,
    String? brand,
    List<String>? sizes,
    List<String>? colors,
    Map<String, dynamic>? specifications,
    double? rating,
    int? reviewCount,
    int? stockQuantity,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      brand: brand ?? this.brand,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
