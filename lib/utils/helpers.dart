import 'package:intl/intl.dart';

class Helpers {
  // Format currency
  static String formatCurrency(double amount, {String currency = '\$'}) {
    final formatter = NumberFormat.currency(symbol: currency, decimalDigits: 2);
    return formatter.format(amount);
  }

  // Format price for display
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Calculate discount percentage
  static double calculateDiscountPercentage(double originalPrice, double discountedPrice) {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100);
  }

  // Format discount percentage
  static String formatDiscountPercentage(double originalPrice, double discountedPrice) {
    double percentage = calculateDiscountPercentage(originalPrice, discountedPrice);
    return '${percentage.toStringAsFixed(0)}% OFF';
  }

  // Format date
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  // Get time ago string
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      int months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Truncate text
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + suffix;
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalize each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Generate star rating widget data
  static String getStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    
    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '☆';
    
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    stars += '☆' * emptyStars;
    
    return stars;
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int digitGroups = (bytes.bitLength / 10).floor();
    
    return '${(bytes / (1 << (digitGroups * 10))).toStringAsFixed(1)} ${units[digitGroups]}';
  }

  // Generate random string
  static String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length]).join();
  }

  // Check if string is valid email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check if string is valid phone number
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  // Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    bool hasMinLength = password.length >= 8;
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigits = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasDigits) score++;
    if (hasSpecialCharacters) score++;
    
    String strength;
    if (score < 2) {
      strength = 'Very Weak';
    } else if (score < 3) {
      strength = 'Weak';
    } else if (score < 4) {
      strength = 'Medium';
    } else if (score < 5) {
      strength = 'Strong';
    } else {
      strength = 'Very Strong';
    }
    
    return {
      'isValid': score >= 3,
      'strength': strength,
      'score': score,
      'hasMinLength': hasMinLength,
      'hasUppercase': hasUppercase,
      'hasLowercase': hasLowercase,
      'hasDigits': hasDigits,
      'hasSpecialCharacters': hasSpecialCharacters,
    };
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
      return '+1 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    
    return phone; // Return original if can't format
  }

  // Calculate estimated delivery date
  static DateTime getEstimatedDeliveryDate({int daysToAdd = 7}) {
    DateTime now = DateTime.now();
    DateTime deliveryDate = now.add(Duration(days: daysToAdd));
    
    // Skip weekends for business delivery
    while (deliveryDate.weekday == DateTime.saturday || deliveryDate.weekday == DateTime.sunday) {
      deliveryDate = deliveryDate.add(const Duration(days: 1));
    }
    
    return deliveryDate;
  }

  // Get delivery date range string
  static String getDeliveryDateRange({int minDays = 5, int maxDays = 7}) {
    DateTime startDate = getEstimatedDeliveryDate(daysToAdd: minDays);
    DateTime endDate = getEstimatedDeliveryDate(daysToAdd: maxDays);
    
    if (startDate.month == endDate.month) {
      return '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('dd').format(endDate)}';
    } else {
      return '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}';
    }
  }

  // Calculate shipping cost
  static double calculateShippingCost(double orderAmount, {double freeShippingThreshold = 50.0}) {
    if (orderAmount >= freeShippingThreshold) {
      return 0.0;
    }
    return 5.99; // Standard shipping cost
  }

  // Calculate tax
  static double calculateTax(double amount, {double taxRate = 0.08}) {
    return amount * taxRate;
  }

  // Get color from hex string
  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add alpha if not provided
    }
    return int.parse(hexColor, radix: 16);
  }

  // Convert color to hex string
  static String colorToHex(int color) {
    return '#${color.toRadixString(16).substring(2).toUpperCase()}';
  }

  // Parse search query for better results
  static List<String> parseSearchQuery(String query) {
    return query
        .toLowerCase()
        .split(' ')
        .where((term) => term.isNotEmpty)
        .toList();
  }

  // Generate order ID
  static String generateOrderId() {
    DateTime now = DateTime.now();
    String timestamp = now.millisecondsSinceEpoch.toString();
    return 'ORD-${timestamp.substring(timestamp.length - 8)}';
  }

  // Get size order for sorting
  static int getSizeOrder(String size) {
    const Map<String, int> sizeOrder = {
      'XXS': 1, 'XS': 2, 'S': 3, 'M': 4, 'L': 5, 'XL': 6, 'XXL': 7, 'XXXL': 8,
    };
    return sizeOrder[size.toUpperCase()] ?? 999;
  }

  // Sort sizes array
  static List<String> sortSizes(List<String> sizes) {
    List<String> sorted = List.from(sizes);
    sorted.sort((a, b) => getSizeOrder(a).compareTo(getSizeOrder(b)));
    return sorted;
  }

  // Check if app needs update (placeholder for version checking)
  static bool shouldShowUpdateDialog(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latest = latestVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      int currentPart = i < current.length ? current[i] : 0;
      int latestPart = i < latest.length ? latest[i] : 0;
      
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    
    return false;
  }
}
