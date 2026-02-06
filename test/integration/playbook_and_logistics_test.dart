import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
import 'package:moving_tool_flutter/features/playbook/application/playbook_service.dart';
import 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_rule.dart';
import 'package:moving_tool_flutter/features/transport/application/transport_advisor_service.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';

void main() {
  group('Logistics & Playbook Integration', () {
    late Project project;
    late TransportAdvisorService advisor;
    late PlaybookService playbook;
    late ProviderContainer container;

    setUp(() {
      advisor = TransportAdvisorService();
      container = ProviderContainer();
      playbook = container.read(playbookServiceProvider);

      project = Project(
        id: 'p1',
        name: 'Test Move',
        movingDate: DateTime.now(),
        fromAddress: const Address(city: 'A'),
        toAddress: const Address(city: 'B'),
        members: [],
        createdAt: DateTime.now(),
        blueprintId: 'standard_move',
        resources: [
          TransportResource(
            id: 't1',
            projectId: 'p1',
            name: 'Car',
            type: TransportType.car,
            capacity: TransportCapacity.medium, // 6m3
            weatherSensitive: false,
            costPerHour: 0,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('TransportAdvisor calculates volume and advice', () {
      final boxes = List.generate(
        10,
        (i) => PackingBox(
          id: '$i',
          roomId: 'r1',
          label: 'Box $i',
          createdAt: DateTime.now(),
        ),
      );

      final advice = advisor.analyzeTransport(project: project, boxes: boxes);

      expect(advice.join(' '), contains('Total Load: 0.6 m³'));
      expect(advice.join(' '), contains('Volume OK'));
    });

    test('TransportAdvisor warns on deficit', () {
      final boxes = List.generate(
        200,
        (i) => PackingBox(
          id: '$i',
          roomId: 'r1',
          label: 'Box $i',
          createdAt: DateTime.now(),
        ),
      );

      final advice = advisor.analyzeTransport(project: project, boxes: boxes);
      expect(advice.join(' '), contains('WARNING'));
      expect(advice.join(' '), contains('Volume deficit of'));
    });

    test('PlaybookService handles basic event without crash', () async {
      await playbook.handleEvent(
        trigger: EventTrigger.expenseAdded,
        project: project,
        context: {'expenseId': 'e1', 'amount': 600.0, 'category': 'food'},
      );
    });
  });
}
