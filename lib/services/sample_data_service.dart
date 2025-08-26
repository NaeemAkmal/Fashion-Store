import '../models/product.dart';
import '../models/category.dart';
import '../models/user.dart';

class SampleDataService {
  static List<Product> getSampleProducts() {
    return [
      Product(
        id: '1',
        name: 'Classic White T-Shirt',
        description: 'A comfortable and stylish white t-shirt made from 100% cotton. Perfect for casual wear.',
        price: 29.99,
        discountPrice: 24.99,
        images: [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500',
          'https://images.unsplash.com/photo-1583743814966-8936f37f3804?w=500',
        ],
        category: 'men',
        subCategory: 'men_shirts',
        brand: 'FashionCo',
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['White', 'Black', 'Gray'],
        specifications: {
          'Material': '100% Cotton',
          'Fit': 'Regular',
          'Care': 'Machine wash cold',
        },
        rating: 4.5,
        reviewCount: 128,
        stockQuantity: 50,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Product(
        id: '2',
        name: 'Elegant Summer Dress',
        description: 'Beautiful floral summer dress perfect for any occasion. Made with lightweight breathable fabric.',
        price: 89.99,
        images: [
          'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=500',
          'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=500',
        ],
        category: 'women',
        subCategory: 'women_dresses',
        brand: 'StylePlus',
        sizes: ['XS', 'S', 'M', 'L'],
        colors: ['Floral', 'Navy', 'Black'],
        specifications: {
          'Material': 'Polyester Blend',
          'Length': 'Midi',
          'Care': 'Hand wash recommended',
        },
        rating: 4.8,
        reviewCount: 95,
        stockQuantity: 25,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: '3',
        name: 'Premium Denim Jeans',
        description: 'High-quality denim jeans with a perfect fit. Comfortable and durable for everyday wear.',
        price: 119.99,
        discountPrice: 89.99,
        images: [
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=500',
          'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=500',
        ],
        category: 'men',
        subCategory: 'men_pants',
        brand: 'DenimPro',
        sizes: ['28', '30', '32', '34', '36'],
        colors: ['Blue', 'Black', 'Gray'],
        specifications: {
          'Material': '100% Cotton Denim',
          'Fit': 'Slim',
          'Care': 'Machine wash',
        },
        rating: 4.3,
        reviewCount: 167,
        stockQuantity: 75,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Product(
        id: '4',
        name: 'Leather Sneakers',
        description: 'Comfortable leather sneakers perfect for casual and semi-formal occasions.',
        price: 149.99,
        images: [
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500',
          'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=500',
        ],
        category: 'men',
        subCategory: 'men_shoes',
        brand: 'FootComfort',
        sizes: ['7', '8', '9', '10', '11'],
        colors: ['White', 'Black', 'Brown'],
        specifications: {
          'Material': 'Genuine Leather',
          'Sole': 'Rubber',
          'Care': 'Wipe with damp cloth',
        },
        rating: 4.6,
        reviewCount: 203,
        stockQuantity: 30,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Product(
        id: '5',
        name: 'Designer Handbag',
        description: 'Elegant designer handbag made from premium materials. Perfect accessory for any outfit.',
        price: 299.99,
        discountPrice: 249.99,
        images: [
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500',
        ],
        category: 'accessories',
        subCategory: 'bags',
        brand: 'LuxuryLine',
        sizes: ['One Size'],
        colors: ['Black', 'Brown', 'Red'],
        specifications: {
          'Material': 'Premium Leather',
          'Dimensions': '12" x 8" x 4"',
          'Care': 'Leather conditioner recommended',
        },
        rating: 4.9,
        reviewCount: 89,
        stockQuantity: 15,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '6',
        name: 'Casual Blazer',
        description: 'Smart casual blazer perfect for business casual and semi-formal events.',
        price: 179.99,
        images: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=500',
        ],
        category: 'men',
        subCategory: 'men_shirts',
        brand: 'BusinessStyle',
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['Navy', 'Gray', 'Black'],
        specifications: {
          'Material': 'Wool Blend',
          'Fit': 'Regular',
          'Care': 'Dry clean only',
        },
        rating: 4.4,
        reviewCount: 156,
        stockQuantity: 20,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  static List<Category> getSampleCategories() {
    return [
      Category(
        id: 'men',
        name: 'Men',
        description: 'Fashion for men',
        image: 'https://images.unsplash.com/photo-1516257984-b1b4d707412e?w=400',
        sortOrder: 1,
        isActive: true,
        subCategoryIds: ['men_shirts', 'men_pants', 'men_shoes'],
      ),
      Category(
        id: 'women',
        name: 'Women',
        description: 'Fashion for women',
        image: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400',
        sortOrder: 2,
        isActive: true,
        subCategoryIds: ['women_dresses', 'women_tops', 'women_shoes'],
      ),
      Category(
        id: 'kids',
        name: 'Kids',
        description: 'Fashion for children',
        image: 'https://images.unsplash.com/photo-1503919005314-30d93d07d823?w=400',
        sortOrder: 3,
        isActive: true,
        subCategoryIds: ['kids_boys', 'kids_girls'],
      ),
      Category(
        id: 'accessories',
        name: 'Accessories',
        description: 'Fashion accessories',
        image: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=400',
        sortOrder: 4,
        isActive: true,
        subCategoryIds: ['bags', 'watches', 'jewelry'],
      ),
    ];
  }

  static User getSampleUser() {
    return User(
      id: 'sample_user_1',
      email: 'user@fashionstore.com',
      name: 'John Doe',
      phoneNumber: '+1234567890',
      profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      addresses: [
        Address(
          id: 'addr_1',
          name: 'Home',
          street: '123 Main Street',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          phoneNumber: '+1234567890',
          isDefault: true,
        ),
        Address(
          id: 'addr_2',
          name: 'Office',
          street: '456 Business Ave',
          city: 'New York',
          state: 'NY',
          zipCode: '10002',
          country: 'USA',
          phoneNumber: '+1234567891',
          isDefault: false,
        ),
      ],
      preferences: UserPreferences(
        preferredSize: 'M',
        favoriteCategories: ['men', 'accessories'],
        favoriteBrands: ['FashionCo', 'StylePlus'],
        emailNotifications: true,
        pushNotifications: true,
      ),
    );
  }

  static List<Map<String, dynamic>> getSampleBanners() {
    return [
      {
        'id': 'banner_1',
        'title': 'Summer Sale',
        'subtitle': 'Up to 50% off on selected items',
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
        'actionType': 'category',
        'actionValue': 'summer_sale',
        'isActive': true,
        'order': 1,
      },
      {
        'id': 'banner_2',
        'title': 'New Arrivals',
        'subtitle': 'Check out our latest collection',
        'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800',
        'actionType': 'category',
        'actionValue': 'new_arrivals',
        'isActive': true,
        'order': 2,
      },
      {
        'id': 'banner_3',
        'title': 'Premium Collection',
        'subtitle': 'Luxury fashion at its finest',
        'image': 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800',
        'actionType': 'category',
        'actionValue': 'premium',
        'isActive': true,
        'order': 3,
      },
    ];
  }

  static List<Map<String, dynamic>> getSampleOffers() {
    return [
      {
        'title': 'Free Shipping',
        'description': 'On orders over \$50',
        'icon': 'local_shipping',
        'color': 0xFF4CAF50,
      },
      {
        'title': '30-Day Returns',
        'description': 'Easy returns policy',
        'icon': 'autorenew',
        'color': 0xFF2196F3,
      },
      {
        'title': '24/7 Support',
        'description': 'Always here to help',
        'icon': 'support_agent',
        'color': 0xFFFF9800,
      },
      {
        'title': 'Secure Payment',
        'description': 'Your data is safe',
        'icon': 'security',
        'color': 0xFF9C27B0,
      },
    ];
  }
}
