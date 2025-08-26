class AppConstants {
  // App Information
  static const String appName = 'Fashion Store';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your ultimate fashion destination';
  
  // API Configuration
  static const String baseUrl = 'https://api.fashionstore.com/v1';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String cartsCollection = 'carts';
  static const String reviewsCollection = 'reviews';
  static const String couponsCollection = 'coupons';
  static const String bannersCollection = 'banners';
  
  // Storage Paths
  static const String productImagesPath = 'products';
  static const String userImagesPath = 'users';
  static const String categoryImagesPath = 'categories';
  static const String bannerImagesPath = 'banners';
  
  // SharedPreferences Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLocationPermission = 'location_permission';
  static const String keyCartItems = 'cart_items';
  static const String keyWishlistItems = 'wishlist_items';
  static const String keySearchHistory = 'search_history';
  static const String keyRecentlyViewed = 'recently_viewed';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int searchResultsLimit = 50;
  static const int wishlistLimit = 500;
  static const int cartItemsLimit = 100;
  
  // Image Configuration
  static const int maxImageFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const int thumbnailSize = 300;
  static const int mediumImageSize = 600;
  static const int largeImageSize = 1200;
  
  // Order Configuration
  static const double freeShippingThreshold = 50.0;
  static const double standardShippingCost = 5.99;
  static const double expressShippingCost = 12.99;
  static const double taxRate = 0.08; // 8%
  static const int orderCancellationWindowHours = 24;
  static const int returnWindowDays = 30;
  
  // Rating Configuration
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  static const int maxReviewCharacters = 1000;
  static const int maxReviewImages = 5;
  
  // Search Configuration
  static const int maxSearchHistoryItems = 20;
  static const int maxRecentlyViewedItems = 50;
  static const int searchDebounceMs = 500;
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxAddressLength = 200;
  
  // Size Options
  static const List<String> clothingSizes = [
    'XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'
  ];
  
  static const List<String> shoeSizes = [
    '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', 
    '9', '9.5', '10', '10.5', '11', '11.5', '12', '12.5', '13'
  ];
  
  // Common Colors
  static const List<String> commonColors = [
    'Black', 'White', 'Gray', 'Navy', 'Blue', 'Red', 'Pink', 
    'Purple', 'Green', 'Yellow', 'Orange', 'Brown', 'Beige'
  ];
  
  // Social Media URLs
  static const String facebookUrl = 'https://facebook.com/fashionstore';
  static const String instagramUrl = 'https://instagram.com/fashionstore';
  static const String twitterUrl = 'https://twitter.com/fashionstore';
  static const String youtubeUrl = 'https://youtube.com/fashionstore';
  
  // Support URLs
  static const String supportEmail = 'support@fashionstore.com';
  static const String supportPhone = '+1-800-FASHION';
  static const String privacyPolicyUrl = 'https://fashionstore.com/privacy';
  static const String termsOfServiceUrl = 'https://fashionstore.com/terms';
  static const String faqUrl = 'https://fashionstore.com/faq';
  static const String shippingInfoUrl = 'https://fashionstore.com/shipping';
  static const String returnPolicyUrl = 'https://fashionstore.com/returns';
  
  // Payment Methods
  static const List<String> supportedPaymentMethods = [
    'Credit Card',
    'Debit Card',
    'PayPal',
    'Google Pay',
    'Apple Pay',
    'Cash on Delivery'
  ];
  
  // Notification Types
  static const String orderStatusNotification = 'order_status';
  static const String promotionNotification = 'promotion';
  static const String newArrivalNotification = 'new_arrival';
  static const String restockNotification = 'restock';
  static const String priceDropNotification = 'price_drop';
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String authErrorMessage = 'Authentication failed. Please sign in again.';
  static const String permissionErrorMessage = 'Permission denied. Please check app permissions.';
  
  // Success Messages
  static const String itemAddedToCartMessage = 'Item added to cart successfully!';
  static const String itemRemovedFromCartMessage = 'Item removed from cart.';
  static const String itemAddedToWishlistMessage = 'Item added to wishlist!';
  static const String itemRemovedFromWishlistMessage = 'Item removed from wishlist.';
  static const String orderPlacedMessage = 'Order placed successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  
  // Animation Durations
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 300;
  static const int longAnimationMs = 500;
  static const int splashScreenMs = 2000;
  
  // Cache Configuration
  static const int imageCacheDays = 7;
  static const int dataCacheMinutes = 30;
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Feature Flags (for A/B testing or gradual rollouts)
  static const bool enableDarkMode = true;
  static const bool enableSocialLogin = true;
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = true;
  static const bool enableAugmentedReality = false;
  static const bool enableVoiceSearch = false;
  static const bool enableChatSupport = true;
  
  // Localization
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'de', 'it'];
  
  // Development Configuration
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}
