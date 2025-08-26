import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/category.dart' as CategoryModel;
import '../services/sample_data_service.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Product> _products = [];
  List<CategoryModel.Category> _categories = [];
  List<Product> _featuredProducts = [];
  List<Product> _searchResults = [];
  List<String> _wishlist = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _error = '';
  
  // Filters
  String _selectedCategory = '';
  String _selectedSubCategory = '';
  String _searchQuery = '';
  double _minPrice = 0;
  double _maxPrice = 1000;
  List<String> _selectedSizes = [];
  List<String> _selectedColors = [];
  List<String> _selectedBrands = [];
  String _sortBy = 'name'; // name, price_low, price_high, rating, newest

  // Getters
  List<Product> get products => _products;
  List<CategoryModel.Category> get categories => _categories;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get searchResults => _searchResults;
  List<String> get wishlist => _wishlist;
  
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get error => _error;
  
  // Filter getters
  String get selectedCategory => _selectedCategory;
  String get selectedSubCategory => _selectedSubCategory;
  String get searchQuery => _searchQuery;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  List<String> get selectedSizes => _selectedSizes;
  List<String> get selectedColors => _selectedColors;
  List<String> get selectedBrands => _selectedBrands;
  String get sortBy => _sortBy;

  // Initialize provider
  Future<void> init() async {
    await loadCategories();
    await loadFeaturedProducts();
    await loadProducts();
  }

  // Load all categories
  Future<void> loadCategories() async {
    try {
      // Use sample data for now
      _categories = SampleDataService.getSampleCategories();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load categories: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    try {
      // Use sample data for now
      List<Product> sampleProducts = SampleDataService.getSampleProducts();
      _featuredProducts = sampleProducts.take(4).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load featured products: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }

  // Load products with filters
  Future<void> loadProducts({bool loadMore = false}) async {
    if (!loadMore) {
      _isLoading = true;
      _products.clear();
    } else {
      _isLoadingMore = true;
    }
    
    _error = '';
    notifyListeners();

    try {
      // Use sample data for now
      List<Product> sampleProducts = SampleDataService.getSampleProducts();
      
      // Apply client-side filters
      List<Product> filteredProducts = _applyClientSideFilters(sampleProducts);
      
      // Apply sorting
      filteredProducts = _applySorting(filteredProducts);
      
      if (loadMore) {
        _products.addAll(filteredProducts);
      } else {
        _products = filteredProducts;
      }

    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      debugPrint(_error);
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  // Apply client-side filters (for complex filters not supported by Firestore)
  List<Product> _applyClientSideFilters(List<Product> products) {
    return products.where((product) {
      // Category filter
      if (_selectedCategory.isNotEmpty && product.category != _selectedCategory) {
        return false;
      }

      // Sub-category filter
      if (_selectedSubCategory.isNotEmpty && product.subCategory != _selectedSubCategory) {
        return false;
      }

      // Brand filter
      if (_selectedBrands.isNotEmpty && !_selectedBrands.contains(product.brand)) {
        return false;
      }

      // Price range filter
      if (product.finalPrice < _minPrice || product.finalPrice > _maxPrice) {
        return false;
      }

      // Size filter
      if (_selectedSizes.isNotEmpty) {
        if (!_selectedSizes.any((size) => product.sizes.contains(size))) {
          return false;
        }
      }

      // Color filter
      if (_selectedColors.isNotEmpty) {
        if (!_selectedColors.any((color) => product.colors.contains(color))) {
          return false;
        }
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        String query = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(query) &&
            !product.description.toLowerCase().contains(query) &&
            !product.brand.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Apply sorting
  List<Product> _applySorting(List<Product> products) {
    List<Product> sortedProducts = List.from(products);
    
    switch (_sortBy) {
      case 'price_low':
        sortedProducts.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;
      case 'price_high':
        sortedProducts.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;
      case 'rating':
        sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        sortedProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
      default:
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return sortedProducts;
  }

  // Get last document value for pagination
  dynamic _getLastDocumentValue() {
    if (_products.isEmpty) return null;
    
    Product lastProduct = _products.last;
    switch (_sortBy) {
      case 'price_low':
      case 'price_high':
        return lastProduct.price;
      case 'rating':
        return lastProduct.rating;
      case 'newest':
        return lastProduct.createdAt;
      default:
        return lastProduct.name;
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Use sample data for search
      List<Product> sampleProducts = SampleDataService.getSampleProducts();
      
      String searchQuery = query.toLowerCase();
      _searchResults = sampleProducts.where((product) {
        return product.name.toLowerCase().contains(searchQuery) ||
               product.description.toLowerCase().contains(searchQuery) ||
               product.brand.toLowerCase().contains(searchQuery) ||
               product.category.toLowerCase().contains(searchQuery);
      }).toList();

      _error = '';
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get product by ID
  Future<Product?> getProduct(String productId) async {
    try {
      // Use sample data for now
      List<Product> sampleProducts = SampleDataService.getSampleProducts();
      return sampleProducts.firstWhere(
        (product) => product.id == productId,
        orElse: () => sampleProducts.first, // Return first product if not found
      );
    } catch (e) {
      _error = 'Failed to get product: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
    return null;
  }

  // Wishlist management
  Future<void> loadWishlist(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc('items')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _wishlist = List<String>.from(data['productIds'] ?? []);
      } else {
        _wishlist.clear();
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load wishlist: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<bool> toggleWishlist(String userId, String productId) async {
    try {
      bool isInWishlist = _wishlist.contains(productId);
      
      if (isInWishlist) {
        _wishlist.remove(productId);
      } else {
        _wishlist.add(productId);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc('items')
          .set({'productIds': _wishlist});

      notifyListeners();
      return !isInWishlist; // Return new state
    } catch (e) {
      _error = 'Failed to update wishlist: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  bool isInWishlist(String productId) {
    return _wishlist.contains(productId);
  }

  // Filter methods
  void setCategory(String category, {String subCategory = ''}) {
    _selectedCategory = category;
    _selectedSubCategory = subCategory;
    loadProducts();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    loadProducts();
  }

  void setSizeFilter(List<String> sizes) {
    _selectedSizes = sizes;
    loadProducts();
  }

  void setColorFilter(List<String> colors) {
    _selectedColors = colors;
    loadProducts();
  }

  void setBrandFilter(List<String> brands) {
    _selectedBrands = brands;
    loadProducts();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    loadProducts();
  }

  void clearFilters() {
    _selectedCategory = '';
    _selectedSubCategory = '';
    _searchQuery = '';
    _minPrice = 0;
    _maxPrice = 1000;
    _selectedSizes.clear();
    _selectedColors.clear();
    _selectedBrands.clear();
    _sortBy = 'name';
    loadProducts();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
