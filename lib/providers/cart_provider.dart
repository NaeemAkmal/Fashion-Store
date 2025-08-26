import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<CartItem> _items = [];
  bool _isLoading = false;
  String _error = '';

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Calculate cart summary
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get subtotal => totalAmount;
  
  double get tax => totalAmount * 0.08; // 8% tax
  
  double get shipping => totalAmount > 50 ? 0.0 : 5.99; // Free shipping over $50
  
  double get finalTotal => subtotal + tax + shipping;
  
  double get total => finalTotal; // Alias for finalTotal

  // Check if a specific product variant is in cart
  bool isInCart(String productId, String size, String color) {
    return _items.any((item) => 
      item.productId == productId && 
      item.selectedSize == size && 
      item.selectedColor == color
    );
  }

  // Get quantity of specific product variant in cart
  int getQuantity(String productId, String size, String color) {
    final item = _items.firstWhere(
      (item) => 
        item.productId == productId && 
        item.selectedSize == size && 
        item.selectedColor == color,
      orElse: () => CartItem(
        id: '',
        productId: '',
        userId: '',
        selectedSize: '',
        selectedColor: '',
        quantity: 0,
        price: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  Future<void> loadCart(String userId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .get();

      _items = snapshot.docs
          .map((doc) => CartItem.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      _error = '';
    } catch (e) {
      _error = 'Failed to load cart: ${e.toString()}';
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(
    Product product, {
    required String userId,
    String selectedSize = '',
    String selectedColor = '',
    int quantity = 1,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if item already exists in cart
      int existingIndex = _items.indexWhere((item) => 
        item.productId == product.id && 
        item.selectedSize == selectedSize && 
        item.selectedColor == selectedColor
      );

      if (existingIndex != -1) {
        // Update existing item
        CartItem existingItem = _items[existingIndex];
        CartItem updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );

        await _firestore
            .collection('carts')
            .doc(existingItem.id)
            .update(updatedItem.toFirestore());

        _items[existingIndex] = updatedItem;
      } else {
        // Add new item
        String cartItemId = _firestore.collection('carts').doc().id;
        
        CartItem newItem = CartItem(
          id: cartItemId,
          productId: product.id,
          userId: userId,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
          quantity: quantity,
          price: product.finalPrice,
          addedAt: DateTime.now(),
          product: product,
        );

        await _firestore
            .collection('carts')
            .doc(cartItemId)
            .set(newItem.toFirestore());

        _items.add(newItem);
      }

      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add to cart: ${e.toString()}';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      return removeFromCart(cartItemId);
    }

    try {
      int index = _items.indexWhere((item) => item.id == cartItemId);
      if (index == -1) return false;

      CartItem updatedItem = _items[index].copyWith(quantity: newQuantity);

      await _firestore
          .collection('carts')
          .doc(cartItemId)
          .update(updatedItem.toFirestore());

      _items[index] = updatedItem;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update quantity: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromCart(String cartItemId) async {
    try {
      await _firestore.collection('carts').doc(cartItemId).delete();
      
      _items.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove from cart: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }


  // Move item to wishlist (if wishlist provider is implemented)
  Future<bool> moveToWishlist(String cartItemId) async {
    try {
      int index = _items.indexWhere((item) => item.id == cartItemId);
      if (index == -1) return false;

      CartItem item = _items[index];
      
      // TODO: Add to wishlist logic here
      // For now, just remove from cart
      return await removeFromCart(cartItemId);
    } catch (e) {
      _error = 'Failed to move to wishlist: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Save cart for later (for guest users)
  Future<void> saveCartLocally() async {
    // TODO: Implement local storage using SharedPreferences
    // This would be useful for guest users or offline functionality
  }

  // Load cart from local storage
  Future<void> loadCartLocally() async {
    // TODO: Implement loading from SharedPreferences
  }

  // Merge local cart with server cart (when user signs in)
  Future<void> mergeCart(String userId) async {
    // TODO: Implement cart merging logic
    // This would merge any locally stored cart items with server cart
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Clear cart (without userId parameter for current user)
  Future<bool> clearCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Delete all cart items
      WriteBatch batch = _firestore.batch();
      for (CartItem item in _items) {
        batch.delete(_firestore.collection('carts').doc(item.id));
      }
      await batch.commit();

      _items.clear();
      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to clear cart: ${e.toString()}';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear cart with userId (keep the existing method)
  Future<bool> clearCartForUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Delete all cart items for this user
      QuerySnapshot snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _items.clear();
      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to clear cart: ${e.toString()}';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check product availability before checkout
  Future<bool> validateCartItems() async {
    try {
      for (CartItem item in _items) {
        if (item.product != null) {
          // Check if product is still available and in stock
          DocumentSnapshot productDoc = await _firestore
              .collection('products')
              .doc(item.productId)
              .get();

          if (!productDoc.exists) {
            _error = 'Product ${item.product!.name} is no longer available';
            notifyListeners();
            return false;
          }

          Product updatedProduct = Product.fromFirestore(
            productDoc.data() as Map<String, dynamic>
          );

          if (!updatedProduct.isAvailable || 
              updatedProduct.stockQuantity < item.quantity) {
            _error = 'Product ${item.product!.name} is out of stock';
            notifyListeners();
            return false;
          }

          // Check if selected size and color are still available
          if (!updatedProduct.sizes.contains(item.selectedSize) ||
              !updatedProduct.colors.contains(item.selectedColor)) {
            _error = 'Selected variant of ${item.product!.name} is no longer available';
            notifyListeners();
            return false;
          }
        }
      }

      _error = '';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to validate cart items: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }
}
