// Domain Models - Project & User (simplified, no HiveObject)
class User {
  final String id;
  final String name;
  final String color;

  User({
    required this.id,
    required this.name,
    required this.color,
  });

  User copyWith({String? name, String? color}) {
    return User(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
  // toJson() removed
}

class Address {
  final String street;
  final String houseNumber;
  final String postalCode;
  final String city;

  Address({
    this.street = '',
    this.houseNumber = '',
    this.postalCode = '',
    this.city = '',
  });

  bool get isEmpty =>
      street.isEmpty && houseNumber.isEmpty && postalCode.isEmpty && city.isEmpty;

  String get fullAddress {
    if (isEmpty) return '';
    return '$street $houseNumber, $postalCode $city';
  }

  Address copyWith({
    String? street,
    String? houseNumber,
    String? postalCode,
    String? city,
  }) {
    return Address(
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
    );
  }
  // toJson() removed
}

class Project {
  final String id;
  final String name;
  final DateTime movingDate;
  final Address fromAddress;
  final Address toAddress;
  final List<User> users;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.movingDate,
    required this.fromAddress,
    required this.toAddress,
    required this.users,
    required this.createdAt,
  });

  int get daysUntilMove {
    final now = DateTime.now();
    return movingDate.difference(now).inDays;
  }

  Project copyWith({
    String? name,
    DateTime? movingDate,
    Address? fromAddress,
    Address? toAddress,
    List<User>? users,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      movingDate: movingDate ?? this.movingDate,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      users: users ?? this.users,
      createdAt: createdAt,
    );
  }
}
