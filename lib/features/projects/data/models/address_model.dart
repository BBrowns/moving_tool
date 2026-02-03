
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class AddressModel extends Address {
  AddressModel({
    super.street,
    super.houseNumber,
    super.postalCode,
    super.city,
  });

  factory AddressModel.fromEntity(Address entity) {
    return AddressModel(
      street: entity.street,
      houseNumber: entity.houseNumber,
      postalCode: entity.postalCode,
      city: entity.city,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'] as String? ?? '',
      houseNumber: json['houseNumber'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      city: json['city'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'houseNumber': houseNumber,
      'postalCode': postalCode,
      'city': city,
    };
  }
}
