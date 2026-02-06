import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

Future<void> seedOnsAppartement(WidgetRef ref) async {
  // 1. Define Members
  final me = ProjectMember(
    id: _uuid.v4(),
    name: 'Ik',
    role: ProjectRole.admin,
    color: '#3498db', // Blue
  );

  final partner = ProjectMember(
    id: _uuid.v4(),
    name: 'Vriend',
    role: ProjectRole.editor,
    color: '#e74c3c', // Red
  );

  // 2. Define Transport
  final bakfiets = TransportResource(
    id: _uuid.v4(),
    projectId: 'temp', // Will update
    name: 'Bakfiets',
    type: TransportType.trailer, // Close enough
    capacity: TransportCapacity.small,
    weatherSensitive: true,
    costPerHour: 0,
  );

  final car = TransportResource(
    id: _uuid.v4(),
    projectId: 'temp',
    name: 'Geleende Auto',
    type: TransportType.car,
    capacity: TransportCapacity.medium,
    weatherSensitive: false,
    costPerHour: 0,
  );

  // 3. Create Project
  final projectId = _uuid.v4();
  final project = Project(
    id: projectId,
    name: 'Ons Appartement',
    movingDate: DateTime.now().add(const Duration(days: 30)),
    fromAddress: const Address(city: 'Oude Stad'),
    toAddress: const Address(city: 'Nieuwe Stad'),
    members: [me, partner],
    createdAt: DateTime.now(),
    blueprintId: 'standard_move',
    resources: [
      bakfiets.copyWith(projectId: projectId),
      car.copyWith(projectId: projectId),
    ],
  );

  // 4. Save to Store
  await ref.read(projectsProvider.notifier).add(project);
}
