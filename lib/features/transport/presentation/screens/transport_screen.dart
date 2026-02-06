import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
import 'package:moving_tool_flutter/features/transport/application/transport_advisor_service.dart';
// import 'package:moving_tool_flutter/features/packing/data/repositories/boxes_repository.dart'; // To get box count

// Riverpod Provider for Transport Advisor
final transportAdvisorProvider = Provider<TransportAdvisorService>((ref) {
  // Pass AI service if available, for now default
  return TransportAdvisorService();
});

// Computed provider for Advisor advice
final transportAdviceProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final project = ref.watch(projectProvider);
  if (project == null) return [];

  // We need boxes to calculate volume.
  // Assuming we have a boxesProvider or repository.
  // For MVP, lets just get all boxes for this project (roomId isn't strictly needed for total count)
  // This might need a new method in BoxesRepository if not efficient, but simple getAll is fine for small projects.
  // Actually, BoxesRepository usually fetches by Room.
  // let's assume we can get a list. Or we iterate rooms.
  // For Quick MVP: let's fetch all via repository if possible or mock the box count from a stats provider.

  // Real implementation: Fetch all boxes
  // final boxes = await ref.read(boxesRepositoryProvider).getAllBoxes(project.id);
  // But we don't have getAllBoxes(projectId) yet easily exposed without iterating rooms.
  // Let's use a simpler approach: Just ask the user to input box count manually OR
  // Iterating all rooms and their boxes is the automated way.

  // Let's stub it for now with empty boxes to show the capacity part,
  // or better, let's inject a dependency that we can implement later.
  // For now: Empty list is fine to just see capacity analysis.

  final advisor = ref.read(transportAdvisorProvider);
  return advisor.analyzeTransport(project: project, boxes: []);
});

class TransportScreen extends ConsumerWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final adviceAsync = ref.watch(transportAdviceProvider);

    if (project == null) {
      return const Center(child: Text('No active project'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Open Add Resource Dialog
              _showAddResourceDialog(context, ref, project);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Advisor Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transport Advisor',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    adviceAsync.when(
                      data: (advice) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: advice.map((e) {
                          final isWarning = e.startsWith('WARNING');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  isWarning
                                      ? Icons.warning_amber
                                      : Icons.info_outline,
                                  color: isWarning ? Colors.red : Colors.blue,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Resources List
            Text(
              'Your Vehicles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (project.resources.isEmpty)
              const Text('No transport resources added yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: project.resources.length,
                itemBuilder: (context, index) {
                  final resource = project.resources[index];
                  return ListTile(
                    leading: Icon(_getIconForType(resource.type)),
                    title: Text(resource.name),
                    subtitle: Text('${resource.capacity.name} capacity'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        _deleteResource(ref, project, resource.id);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(TransportType type) {
    switch (type) {
      case TransportType.legs:
        return Icons.directions_walk;
      case TransportType.car:
        return Icons.directions_car;
      case TransportType.van:
        return Icons.airport_shuttle;
      case TransportType.truck:
        return Icons.local_shipping;
      case TransportType.trailer:
        return Icons.directions_bus; // best approximate or cart
    }
  }

  void _deleteResource(WidgetRef ref, Project project, String resourceId) {
    final updatedResources = project.resources
        .where((r) => r.id != resourceId)
        .toList();
    final updatedProject = project.copyWith(resources: updatedResources);
    ref.read(projectProvider.notifier).save(updatedProject);
  }

  void _showAddResourceDialog(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    // Simple MVP Dialog
    showDialog<void>(
      context: context,
      builder: (context) {
        String name = '';
        TransportType type = TransportType.car;
        TransportCapacity capacity = TransportCapacity.medium;

        return AlertDialog(
          title: const Text('Add Transport'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Name (e.g. My Car)',
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<TransportType>(
                    value: type,
                    isExpanded: true,
                    onChanged: (val) => setState(() => type = val!),
                    items: TransportType.values
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<TransportCapacity>(
                    value: capacity,
                    isExpanded: true,
                    onChanged: (val) => setState(() => capacity = val!),
                    items: TransportCapacity.values
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newResource = TransportResource(
                  id: DateTime.now().millisecondsSinceEpoch
                      .toString(), // Simple ID
                  projectId: project.id,
                  name: name.isEmpty ? 'Untitled' : name,
                  type: type,
                  capacity: capacity,
                  weatherSensitive: false, // Default for now
                  costPerHour: 0,
                );

                final updatedResources = [...project.resources, newResource];
                final updatedProject = project.copyWith(
                  resources: updatedResources,
                );

                ref.read(projectProvider.notifier).save(updatedProject);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
