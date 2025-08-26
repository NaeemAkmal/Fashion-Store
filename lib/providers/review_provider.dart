import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/review.dart';

class ReviewProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Map<String, List<Review>> _productReviews = {};
  Map<String, ReviewSummary> _reviewSummaries = {};
  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  List<Review> getProductReviews(String productId) {
    return _productReviews[productId] ?? [];
  }

  ReviewSummary getReviewSummary(String productId) {
    return _reviewSummaries[productId] ?? ReviewSummary.empty();
  }

  Future<void> loadReviews(String productId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      final reviews = querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc.data()))
          .toList();

      _productReviews[productId] = reviews;
      _reviewSummaries[productId] = ReviewSummary.fromReviews(reviews);
      _error = '';
    } catch (e) {
      _error = 'Failed to load reviews: ${e.toString()}';
      if (kDebugMode) {
        print(_error);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReview({
    required String productId,
    required String userId,
    required String userName,
    String userImageUrl = '',
    required double rating,
    String title = '',
    required String comment,
    List<String> images = const [],
    bool isVerifiedPurchase = false,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final reviewId = _uuid.v4();
      final now = DateTime.now();

      final review = Review(
        id: reviewId,
        productId: productId,
        userId: userId,
        userName: userName,
        userImage: userImageUrl.isNotEmpty ? userImageUrl : null,
        rating: rating,
        title: title,
        comment: comment,
        images: images,
        createdAt: now,
        updatedAt: now,
        isVerifiedPurchase: isVerifiedPurchase,
      );

      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .set(review.toFirestore());

      // Update local cache
      if (_productReviews[productId] != null) {
        _productReviews[productId]!.insert(0, review);
        _reviewSummaries[productId] = ReviewSummary.fromReviews(_productReviews[productId]!);
      }

      // Update product rating
      await _updateProductRating(productId);

      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add review: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print(_error);
      }
      return false;
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    String? title,
    String? comment,
    double? rating,
    List<String>? images,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updateData['title'] = title;
      if (comment != null) updateData['comment'] = comment;
      if (rating != null) updateData['rating'] = rating;
      if (images != null) updateData['images'] = images;

      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .update(updateData);

      // Update local cache
      for (final productId in _productReviews.keys) {
        final reviews = _productReviews[productId]!;
        final index = reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          final oldReview = reviews[index];
          final updatedReview = oldReview.copyWith(
            title: title ?? oldReview.title,
            comment: comment ?? oldReview.comment,
            rating: rating ?? oldReview.rating,
            images: images ?? oldReview.images,
            updatedAt: DateTime.now(),
          );
          reviews[index] = updatedReview;
          _reviewSummaries[productId] = ReviewSummary.fromReviews(reviews);
          
          // Update product rating if rating changed
          if (rating != null) {
            await _updateProductRating(productId);
          }
          break;
        }
      }

      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update review: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print(_error);
      }
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId, String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('reviews').doc(reviewId).delete();

      // Update local cache
      if (_productReviews[productId] != null) {
        _productReviews[productId]!.removeWhere((r) => r.id == reviewId);
        _reviewSummaries[productId] = ReviewSummary.fromReviews(_productReviews[productId]!);
      }

      // Update product rating
      await _updateProductRating(productId);

      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete review: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print(_error);
      }
      return false;
    }
  }

  Future<bool> toggleHelpful(String reviewId, String userId) async {
    try {
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      
      if (!reviewDoc.exists) return false;

      final reviewData = reviewDoc.data()!;
      final helpfulUserIds = List<String>.from(reviewData['helpfulUserIds'] ?? []);
      final currentCount = reviewData['helpfulCount'] ?? 0;

      bool isCurrentlyHelpful = helpfulUserIds.contains(userId);
      
      if (isCurrentlyHelpful) {
        helpfulUserIds.remove(userId);
      } else {
        helpfulUserIds.add(userId);
      }

      await _firestore.collection('reviews').doc(reviewId).update({
        'helpfulUserIds': helpfulUserIds,
        'helpfulCount': helpfulUserIds.length,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update local cache
      for (final productId in _productReviews.keys) {
        final reviews = _productReviews[productId]!;
        final index = reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          final updatedReview = reviews[index].copyWith(
            helpfulCount: helpfulUserIds.length,
            updatedAt: DateTime.now(),
          );
          reviews[index] = updatedReview;
          break;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update helpful status: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print(_error);
      }
      return false;
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      final summary = _reviewSummaries[productId];
      if (summary != null) {
        await _firestore.collection('products').doc(productId).update({
          'rating': summary.averageRating,
          'reviewCount': summary.totalReviews,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update product rating: $e');
      }
    }
  }

  Future<List<Review>> getUserReviews(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      _error = 'Failed to load user reviews: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print(_error);
      }
      return [];
    }
  }

  Future<bool> hasUserReviewedProduct(String userId, String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user review: $e');
      }
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearCache() {
    _productReviews.clear();
    _reviewSummaries.clear();
    notifyListeners();
  }
}
