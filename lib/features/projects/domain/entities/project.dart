import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';

enum ProjectRole {
  owner,
  admin,
  editor,
  viewer;

  bool get canEdit =>
      this == ProjectRole.owner ||
      this == ProjectRole.admin ||
      this == ProjectRole.editor;
  bool get isAdmin => this == ProjectRole.owner || this == ProjectRole.admin;
}

class ProjectMember {
  const ProjectMember({
    required this.id,
    required this.name,
    required this.role,
    this.photoUrl,
    this.color = '#808080', // Default grey
  });

  final String id;
  final String name;
  final ProjectRole role;
  final String? photoUrl;
  final String color;

  ProjectMember copyWith({
    String? name,
    ProjectRole? role,
    String? photoUrl,
    String? color,
  }) {
    return ProjectMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      color: color ?? this.color,
    );
  }
}

class Address {
  const Address({
    this.street = '',
    this.houseNumber = '',
    this.postalCode = '',
    this.city = '',
  });

  final String street;
  final String houseNumber;
  final String postalCode;
  final String city;

  bool get isEmpty =>
      street.isEmpty &&
      houseNumber.isEmpty &&
      postalCode.isEmpty &&
      city.isEmpty;

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
}

// Forward declaration to avoid circular imports if TransportResource is moved later.
// For now, we will assume generic Object or dynamic until TransportResource is created,
// OR we create TransportResource immediately in the next steps.
// To keep code compilable without the file existing yet, I'll temporarily use dynamic or comment,
// BUT the plan is to implement it. I'll stick to 'dynamic' or just exclude it for this specific ReplacementChunk
// and add it in a subsequent edit once TransportResource exists, OR I can define a placeholder class here.
// Better approach: I'll define the class here temporarily or import it if I was creating it in parallel.
// Since I haven't created TransportResource yet, I'll allow the resources list to be defined as List<dynamic>
// or simpler, I will CREATE TransportResource in the same step (next tool call) and include the import.
// To be safe and atomic, I'll omit the resources field in THIS chunk and add it in the next pass
// when I add the TransportResource file, OR I can just refer to it and fixing the import later.
// I'll refer to it as `List<TransportResource>` but I MUST ensure I create the file immediately after.

class Project {
  Project({
    required this.id,
    required this.name,
    required this.movingDate,
    required this.fromAddress,
    required this.toAddress,
    required this.members,
    required this.createdAt,
    this.blueprintId = 'standard_move', // Default blueprint
    this.resources = const [],
  });

  final String id;
  final String name;
  final DateTime movingDate;
  final Address fromAddress;
  final Address toAddress;
  final List<ProjectMember> members;
  final DateTime createdAt;
  final String blueprintId;
  final List<TransportResource> resources;

  int get daysUntilMove {
    final now = DateTime.now();
    return movingDate.difference(now).inDays;
  }

  Project copyWith({
    String? name,
    DateTime? movingDate,
    Address? fromAddress,
    Address? toAddress,
    List<ProjectMember>? members,
    String? blueprintId,
    List<TransportResource>? resources,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      movingDate: movingDate ?? this.movingDate,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      members: members ?? this.members,
      createdAt: createdAt,
      blueprintId: blueprintId ?? this.blueprintId,
      resources: resources ?? this.resources,
    );
  }
}
