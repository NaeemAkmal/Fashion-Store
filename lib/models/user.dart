class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Address> addresses;
  final UserPreferences preferences;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    this.addresses = const [],
    required this.preferences,
  });

  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'],
      profileImage: data['profileImage'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      addresses: (data['addresses'] as List<dynamic>?)
              ?.map((addr) => Address.fromMap(Map<String, dynamic>.from(addr)))
              .toList() ??
          [],
      preferences: data['preferences'] != null
          ? UserPreferences.fromMap(Map<String, dynamic>.from(data['preferences']))
          : UserPreferences(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
      'preferences': preferences.toMap(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Address>? addresses,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addresses: addresses ?? this.addresses,
      preferences: preferences ?? this.preferences,
    );
  }
}

class Address {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.phoneNumber = '',
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
      country: data['country'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    return '$street, $city, $state $zipCode, $country';
  }

  Address copyWith({
    String? id,
    String? name,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phoneNumber,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class UserPreferences {
  final String preferredSize;
  final List<String> favoriteCategories;
  final List<String> favoriteBrands;
  final bool emailNotifications;
  final bool pushNotifications;

  UserPreferences({
    this.preferredSize = 'M',
    this.favoriteCategories = const [],
    this.favoriteBrands = const [],
    this.emailNotifications = true,
    this.pushNotifications = true,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> data) {
    return UserPreferences(
      preferredSize: data['preferredSize'] ?? 'M',
      favoriteCategories: List<String>.from(data['favoriteCategories'] ?? []),
      favoriteBrands: List<String>.from(data['favoriteBrands'] ?? []),
      emailNotifications: data['emailNotifications'] ?? true,
      pushNotifications: data['pushNotifications'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preferredSize': preferredSize,
      'favoriteCategories': favoriteCategories,
      'favoriteBrands': favoriteBrands,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
    };
  }

  UserPreferences copyWith({
    String? preferredSize,
    List<String>? favoriteCategories,
    List<String>? favoriteBrands,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return UserPreferences(
      preferredSize: preferredSize ?? this.preferredSize,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      favoriteBrands: favoriteBrands ?? this.favoriteBrands,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}
