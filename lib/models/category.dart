class Category {
  final String id;
  final String name;
  final String description;
  final String image;
  final String parentId; // For subcategories
  final int sortOrder;
  final bool isActive;
  final List<String> subCategoryIds;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.parentId = '',
    this.sortOrder = 0,
    this.isActive = true,
    this.subCategoryIds = const [],
  });

  // Check if this is a main category (no parent)
  bool get isMainCategory => parentId.isEmpty;

  // Check if this is a subcategory (has parent)
  bool get isSubCategory => parentId.isNotEmpty;

  factory Category.fromFirestore(Map<String, dynamic> data) {
    return Category(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      parentId: data['parentId'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      subCategoryIds: List<String>.from(data['subCategoryIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'parentId': parentId,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'subCategoryIds': subCategoryIds,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? parentId,
    int? sortOrder,
    bool? isActive,
    List<String>? subCategoryIds,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      subCategoryIds: subCategoryIds ?? this.subCategoryIds,
    );
  }
}

// Predefined fashion categories
class FashionCategories {
  static const List<Map<String, dynamic>> mainCategories = [
    {
      'id': 'men',
      'name': 'Men',
      'description': 'Fashion for men',
      'image': 'assets/categories/men.jpg',
      'subCategories': ['men_shirts', 'men_pants', 'men_shoes', 'men_accessories']
    },
    {
      'id': 'women',
      'name': 'Women',
      'description': 'Fashion for women',
      'image': 'assets/categories/women.jpg',
      'subCategories': ['women_dresses', 'women_tops', 'women_bottoms', 'women_shoes', 'women_accessories']
    },
    {
      'id': 'kids',
      'name': 'Kids',
      'description': 'Fashion for children',
      'image': 'assets/categories/kids.jpg',
      'subCategories': ['kids_boys', 'kids_girls', 'kids_baby']
    },
    {
      'id': 'accessories',
      'name': 'Accessories',
      'description': 'Fashion accessories',
      'image': 'assets/categories/accessories.jpg',
      'subCategories': ['bags', 'watches', 'jewelry', 'sunglasses']
    },
  ];

  static const List<Map<String, dynamic>> subCategories = [
    // Men subcategories
    {'id': 'men_shirts', 'name': 'Shirts', 'parentId': 'men'},
    {'id': 'men_pants', 'name': 'Pants', 'parentId': 'men'},
    {'id': 'men_shoes', 'name': 'Shoes', 'parentId': 'men'},
    {'id': 'men_accessories', 'name': 'Accessories', 'parentId': 'men'},
    
    // Women subcategories
    {'id': 'women_dresses', 'name': 'Dresses', 'parentId': 'women'},
    {'id': 'women_tops', 'name': 'Tops', 'parentId': 'women'},
    {'id': 'women_bottoms', 'name': 'Bottoms', 'parentId': 'women'},
    {'id': 'women_shoes', 'name': 'Shoes', 'parentId': 'women'},
    {'id': 'women_accessories', 'name': 'Accessories', 'parentId': 'women'},
    
    // Kids subcategories
    {'id': 'kids_boys', 'name': 'Boys', 'parentId': 'kids'},
    {'id': 'kids_girls', 'name': 'Girls', 'parentId': 'kids'},
    {'id': 'kids_baby', 'name': 'Baby', 'parentId': 'kids'},
    
    // Accessories subcategories
    {'id': 'bags', 'name': 'Bags', 'parentId': 'accessories'},
    {'id': 'watches', 'name': 'Watches', 'parentId': 'accessories'},
    {'id': 'jewelry', 'name': 'Jewelry', 'parentId': 'accessories'},
    {'id': 'sunglasses', 'name': 'Sunglasses', 'parentId': 'accessories'},
  ];
}
