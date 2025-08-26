import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart' as OrderModel;
import '../models/cart_item.dart';
import '../models/user.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  List<OrderModel.Order> _orders = [];
  bool _isLoading = false;
  String _error = '';

  List<OrderModel.Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Alias for loadOrders to match the profile screen usage
  Future<void> loadUserOrders(String userId) async {
    return loadOrders(userId);
  }

  // Load user orders
  Future<void> loadOrders(String userId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.Order.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      _error = '';
    } catch (e) {
      _error = 'Failed to load orders: ${e.toString()}';
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create new order
  Future<OrderModel.Order?> createOrder({
    required String userId,
    required List<CartItem> items,
    required Address shippingAddress,
    Address? billingAddress,
    String? paymentMethod,
    String? couponCode,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Calculate order totals
      double subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      double tax = subtotal * 0.08; // 8% tax
      double shippingCost = subtotal > 50 ? 0.0 : 5.99; // Free shipping over $50
      double discount = 0.0;

      // Apply coupon discount if provided
      if (couponCode != null) {
        discount = await _calculateCouponDiscount(couponCode, subtotal);
      }

      double totalAmount = subtotal + tax + shippingCost - discount;

      String orderId = _uuid.v4();

      OrderModel.Order newOrder = OrderModel.Order(
        id: orderId,
        userId: userId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shippingCost: shippingCost,
        discount: discount,
        totalAmount: totalAmount,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress ?? shippingAddress,
        status: OrderModel.OrderStatus.pending,
        paymentStatus: OrderModel.PaymentStatus.pending,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('orders')
          .doc(orderId)
          .set(newOrder.toFirestore());

      _orders.insert(0, newOrder);
      _error = '';
      _isLoading = false;
      notifyListeners();

      return newOrder;
    } catch (e) {
      _error = 'Failed to create order: ${e.toString()}';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderModel.OrderStatus newStatus) async {
    try {
      int index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) return false;

      OrderModel.Order updatedOrder = _orders[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        deliveredAt: newStatus == OrderModel.OrderStatus.delivered ? DateTime.now() : null,
      );

      await _firestore
          .collection('orders')
          .doc(orderId)
          .update(updatedOrder.toFirestore());

      _orders[index] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update order status: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(
    String orderId, 
    OrderModel.PaymentStatus paymentStatus, {
    String? paymentId,
  }) async {
    try {
      int index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) return false;

      OrderModel.Order updatedOrder = _orders[index].copyWith(
        paymentStatus: paymentStatus,
        paymentId: paymentId,
        updatedAt: DateTime.now(),
        // If payment is successful, move order to confirmed status
        status: paymentStatus == OrderModel.PaymentStatus.paid ? OrderModel.OrderStatus.confirmed : _orders[index].status,
      );

      await _firestore
          .collection('orders')
          .doc(orderId)
          .update(updatedOrder.toFirestore());

      _orders[index] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update payment status: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      int index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) return false;

      OrderModel.Order order = _orders[index];
      if (!order.canBeCancelled) {
        _error = 'Order cannot be cancelled at this stage';
        notifyListeners();
        return false;
      }

      OrderModel.Order updatedOrder = order.copyWith(
        status: OrderModel.OrderStatus.cancelled,
        updatedAt: DateTime.now(),
        notes: reason,
      );

      await _firestore
          .collection('orders')
          .doc(orderId)
          .update(updatedOrder.toFirestore());

      _orders[index] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to cancel order: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Add tracking number
  Future<bool> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      int index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) return false;

      OrderModel.Order updatedOrder = _orders[index].copyWith(
        trackingNumber: trackingNumber,
        status: OrderModel.OrderStatus.shipped,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('orders')
          .doc(orderId)
          .update(updatedOrder.toFirestore());

      _orders[index] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add tracking number: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Get order by ID
  OrderModel.Order? getOrder(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Get orders by status
  List<OrderModel.Order> getOrdersByStatus(OrderModel.OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get recent orders
  List<OrderModel.Order> getRecentOrders({int limit = 5}) {
    List<OrderModel.Order> sortedOrders = List.from(_orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(limit).toList();
  }

  // Calculate order statistics
  Map<String, dynamic> getOrderStatistics() {
    if (_orders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalSpent': 0.0,
        'averageOrderValue': 0.0,
        'completedOrders': 0,
        'cancelledOrders': 0,
      };
    }

    int totalOrders = _orders.length;
    double totalSpent = _orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    double averageOrderValue = totalSpent / totalOrders;
    int completedOrders = _orders.where((order) => order.isCompleted).length;
    int cancelledOrders = _orders.where((order) => order.isCancelled).length;

    return {
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'averageOrderValue': averageOrderValue,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
    };
  }

  // Process refund
  Future<bool> processRefund(String orderId, double refundAmount) async {
    try {
      int index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) return false;

      OrderModel.Order updatedOrder = _orders[index].copyWith(
        paymentStatus: OrderModel.PaymentStatus.refunded,
        status: OrderModel.OrderStatus.returned,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('orders')
          .doc(orderId)
          .update(updatedOrder.toFirestore());

      // TODO: Integrate with payment gateway to process actual refund

      _orders[index] = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to process refund: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Calculate coupon discount
  Future<double> _calculateCouponDiscount(String couponCode, double subtotal) async {
    try {
      DocumentSnapshot couponDoc = await _firestore
          .collection('coupons')
          .doc(couponCode)
          .get();

      if (couponDoc.exists) {
        Map<String, dynamic> couponData = couponDoc.data() as Map<String, dynamic>;
        
        bool isActive = couponData['isActive'] ?? false;
        DateTime expiryDate = (couponData['expiryDate'] as Timestamp).toDate();
        double minOrderAmount = (couponData['minOrderAmount'] ?? 0).toDouble();
        
        if (isActive && 
            DateTime.now().isBefore(expiryDate) && 
            subtotal >= minOrderAmount) {
          
          String discountType = couponData['type'] ?? 'percentage';
          double discountValue = (couponData['value'] ?? 0).toDouble();
          
          if (discountType == 'percentage') {
            return subtotal * (discountValue / 100);
          } else if (discountType == 'fixed') {
            return discountValue;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to calculate coupon discount: ${e.toString()}');
    }
    return 0.0;
  }

  // Validate coupon
  Future<Map<String, dynamic>> validateCoupon(String couponCode, double subtotal) async {
    try {
      DocumentSnapshot couponDoc = await _firestore
          .collection('coupons')
          .doc(couponCode)
          .get();

      if (!couponDoc.exists) {
        return {'isValid': false, 'message': 'Invalid coupon code'};
      }

      Map<String, dynamic> couponData = couponDoc.data() as Map<String, dynamic>;
      
      bool isActive = couponData['isActive'] ?? false;
      DateTime expiryDate = (couponData['expiryDate'] as Timestamp).toDate();
      double minOrderAmount = (couponData['minOrderAmount'] ?? 0).toDouble();
      int usageLimit = couponData['usageLimit'] ?? 0;
      int currentUsage = couponData['currentUsage'] ?? 0;
      
      if (!isActive) {
        return {'isValid': false, 'message': 'This coupon is no longer active'};
      }
      
      if (DateTime.now().isAfter(expiryDate)) {
        return {'isValid': false, 'message': 'This coupon has expired'};
      }
      
      if (subtotal < minOrderAmount) {
        return {
          'isValid': false, 
          'message': 'Minimum order amount of \$${minOrderAmount.toStringAsFixed(2)} required'
        };
      }
      
      if (usageLimit > 0 && currentUsage >= usageLimit) {
        return {'isValid': false, 'message': 'This coupon has reached its usage limit'};
      }

      double discount = await _calculateCouponDiscount(couponCode, subtotal);
      
      return {
        'isValid': true,
        'discount': discount,
        'message': 'Coupon applied successfully!'
      };
    } catch (e) {
      debugPrint('Failed to validate coupon: ${e.toString()}');
      return {'isValid': false, 'message': 'Failed to validate coupon'};
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
