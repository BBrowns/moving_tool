import 'package:moving_tool_flutter/features/projects/data/models/address_model.dart';
import 'package:moving_tool_flutter/features/projects/data/models/project_member_model.dart';
import 'package:moving_tool_flutter/features/projects/data/models/transport_resource_model.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';

class ProjectModel extends Project {
  ProjectModel({
    required super.id,
    required super.name,
    required super.movingDate,
    required super.fromAddress,
    required super.toAddress,
    required super.members,
    required super.createdAt,
    super.blueprintId,
    super.resources = const [],
  });

  factory ProjectModel.fromEntity(Project entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      movingDate: entity.movingDate,
      fromAddress: entity.fromAddress is AddressModel
          ? entity.fromAddress
          : AddressModel.fromEntity(entity.fromAddress),
      toAddress: entity.toAddress is AddressModel
          ? entity.toAddress
          : AddressModel.fromEntity(entity.toAddress),
      members: entity.members
          .map(
            (u) =>
                u is ProjectMemberModel ? u : ProjectMemberModel.fromEntity(u),
          )
          .toList(),
      createdAt: entity.createdAt,
      blueprintId: entity.blueprintId,
      resources: entity.resources
          .map(
            (r) => r is TransportResourceModel
                ? r
                : TransportResourceModel.fromEntity(r),
          )
          .toList(),
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      movingDate: DateTime.parse(json['movingDate'] as String),
      fromAddress: AddressModel.fromJson(
        json['fromAddress'] as Map<String, dynamic>,
      ),
      toAddress: AddressModel.fromJson(
        json['toAddress'] as Map<String, dynamic>,
      ),
      members:
          (json['members'] as List<dynamic>?)
              ?.map(
                (e) => ProjectMemberModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [], // Fallback for old data: generic "Owner" from old 'users' list? Complex migration.
      // For dev environment, we accept empty or require data reset.
      // Actually, let's try to migrate old 'users' if 'members' is null
      createdAt: DateTime.parse(json['createdAt'] as String),
      blueprintId: json['blueprintId'] as String? ?? 'standard_move',
      resources:
          (json['resources'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TransportResourceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
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
      'members': members
          .map(
            (u) => (u is ProjectMemberModel
                ? (u).toJson()
                : ProjectMemberModel.fromEntity(u).toJson()),
          )
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'blueprintId': blueprintId,
      'resources': resources
          .map(
            (r) => (r is TransportResourceModel
                ? (r).toJson()
                : TransportResourceModel.fromEntity(r).toJson()),
          )
          .toList(),
    };
  }
}
