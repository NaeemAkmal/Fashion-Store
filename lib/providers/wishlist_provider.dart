import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class WishlistProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> _items = [];
  bool _isLoading = false;
  String _error = '';
  String? _userId;

  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get itemCount => _items.length;

  void setUserId(String? userId) {
    _userId = userId;
    if (userId == null) {
      _items.clear();
      notifyListeners();
    } else {
      loadWishlist();
    }
  }

  Future<void> loadWishlist() async {
    if (_userId == null) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _items = await _firebaseService.getWishlistItems(_userId!);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading wishlist: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWishlist(String productId) async {
    if (_userId == null) return;

    try {
      await _firebaseService.addToWishlist(_userId!, productId);
      
      // Get the product details and add to local list
      final product = await _firebaseService.getProduct(productId);
      if (product != null && !_items.any((item) => item.id == productId)) {
        _items.add(product);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error adding to wishlist: $e');
      }
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    if (_userId == null) return;

    // Optimistically remove from local list
    final removedItem = _items.firstWhere(
      (item) => item.id == productId,
      orElse: () => Product(
        id: '',
        name: '',
        description: '',
        price: 0,
        images: [],
        category: '',
        subCategory: '',
        brand: '',
        sizes: [],
        colors: [],
        specifications: {},
        stockQuantity: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    _items.removeWhere((item) => item.id == productId);
    notifyListeners();

    try {
      await _firebaseService.removeFromWishlist(_userId!, productId);
    } catch (e) {
      // Revert if error
      if (removedItem.id.isNotEmpty) {
        _items.add(removedItem);
      }
      _error = e.toString();
      if (kDebugMode) {
        print('Error removing from wishlist: $e');
      }
      notifyListeners();
    }
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  Future<void> toggleWishlist(String productId) async {
    if (isInWishlist(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  Future<void> clearWishlist() async {
    if (_userId == null) return;

    try {
      await _firebaseService.clearWishlist(_userId!);
      _items.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error clearing wishlist: $e');
      }
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
