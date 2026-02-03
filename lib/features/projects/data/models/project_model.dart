
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/data/models/address_model.dart';
import 'package:moving_tool_flutter/features/projects/data/models/user_model.dart';

class ProjectModel extends Project {
  ProjectModel({
    required super.id,
    required super.name,
    required super.movingDate,
    required super.fromAddress,
    required super.toAddress,
    required super.users,
    required super.createdAt,
  });

  factory ProjectModel.fromEntity(Project entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      movingDate: entity.movingDate,
      fromAddress: entity.fromAddress is AddressModel ? entity.fromAddress : AddressModel.fromEntity(entity.fromAddress),
      toAddress: entity.toAddress is AddressModel ? entity.toAddress : AddressModel.fromEntity(entity.toAddress),
      users: entity.users.map((u) => u is UserModel ? u : UserModel.fromEntity(u)).toList(),
      createdAt: entity.createdAt,
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      movingDate: DateTime.parse(json['movingDate'] as String),
      fromAddress: AddressModel.fromJson(json['fromAddress'] as Map<String, dynamic>),
      toAddress: AddressModel.fromJson(json['toAddress'] as Map<String, dynamic>),
      users: (json['users'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'movingDate': movingDate.toIso8601String(),
      'fromAddress': (fromAddress is AddressModel 
          ? (fromAddress as AddressModel).toJson() 
          : AddressModel.fromEntity(fromAddress).toJson()),
      'toAddress': (toAddress is AddressModel 
          ? (toAddress as AddressModel).toJson() 
          : AddressModel.fromEntity(toAddress).toJson()),
      'users': users.map((u) => (u is UserModel 
          ? (u).toJson() 
          : UserModel.fromEntity(u).toJson())).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
