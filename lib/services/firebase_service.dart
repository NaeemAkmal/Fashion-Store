import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart' as OrderModel;
import '../services/sample_data_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Product operations
  Future<Product?> getProduct(String productId) async {
    try {
      // For now, use sample data
      final sampleProducts = SampleDataService.getSampleProducts();
      return sampleProducts.firstWhere(
        (product) => product.id == productId,
        orElse: () => sampleProducts.first,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting product: $e');
      }
      return null;
    }
  }

  Future<List<Product>> getProducts({
    String? categoryId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      // For now, return sample data
      final sampleProducts = SampleDataService.getSampleProducts();
      if (categoryId != null && categoryId.isNotEmpty) {
        return sampleProducts.where((p) => p.category == categoryId).toList();
      }
      return sampleProducts;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting products: $e');
      }
      return [];
    }
  }

  // Wishlist operations
  Future<List<Product>> getWishlistItems(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc('items')
          .get();

      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>?;
      final productIds = List<String>.from(data?['productIds'] ?? []);

      // Get product details for each ID
      final products = <Product>[];
      for (final productId in productIds) {
        final product = await getProduct(productId);
        if (product != null) {
          products.add(product);
        }
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting wishlist items: $e');
      }
      return [];
    }
  }

  Future<void> addToWishlist(String userId, String productId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc('items');

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        List<String> productIds = [];
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          productIds = List<String>.from(data?['productIds'] ?? []);
        }

        if (!productIds.contains(productId)) {
          productIds.add(productId);
          transaction.set(docRef, {
            'productIds': productIds,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding to wishlist: $e');
      }
      throw e;
    }
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc('items');

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          List<String> productIds =
              List<String>.from(data?['productIds'] ?? []);

          productIds.remove(productId);
          transaction.set(docRef, {
            'productIds': productIds,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error removing from wishlist: $e');
      }
      throw e;
    }
  }

  Future<void> clearWishlist(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc('items')
          .set({
        'productIds': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing wishlist: $e');
      }
      throw e;
    }
  }

  // Order operations
  Future<List<OrderModel.Order>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to data
        return OrderModel.Order.fromFirestore(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user orders: $e');
      }
      return [];
    }
  }

  Future<String> createOrder(OrderModel.Order order) async {
    try {
      final docRef =
          await _firestore.collection('orders').add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating order: $e');
      }
      throw e;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating order status: $e');
      }
      throw e;
    }
  }
}
