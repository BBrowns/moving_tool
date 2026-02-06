import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/core/models/item_dimensions.dart';
import 'package:moving_tool_flutter/features/transport/application/transport_advisor_service.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';

void main() {
  late TransportAdvisorService service;

  setUp(() {
    service = TransportAdvisorService();
  });

  group('TransportAdvisorService Fit Logic', () {
    final smallVehicle = TransportResource(
      id: 'v1',
      projectId: 'p1',
      name: 'Small Car',
      type: TransportType.car,
      capacity: TransportCapacity.small, // 120x100x80
      weatherSensitive: true,
      costPerHour: 0,
    );

    final largeVehicle = TransportResource(
      id: 'v2',
      projectId: 'p1',
      name: 'Large Van',
      type: TransportType.van,
      capacity: TransportCapacity.large, // 320x180x190
      weatherSensitive: false,
      costPerHour: 50,
    );

    test('Item that fits in small vehicle', () {
      const item = ItemDimensions(heightCm: 50, widthCm: 50, depthCm: 50);

      final result = service.checkPhysicalFit(item, smallVehicle);
      expect(result, isNull, reason: 'A 50x50x50 box should fit in a car');
    });

    test('Item too large for any orientation in small vehicle', () {
      const item = ItemDimensions(
        heightCm: 150, // Car max height is ~80, depth is 120
        widthCm: 110, // Car max width is 100
        depthCm: 50,
      );

      final result = service.checkPhysicalFit(item, smallVehicle);
      expect(result, isNotNull, reason: 'Item should be too large');
    });

    test('Item that only fits in large vehicle', () {
      const longItem = ItemDimensions(
        heightCm: 10,
        widthCm: 10,
        depthCm: 200, // Too long for car (120), but fits in van (320)
      );

      expect(service.checkPhysicalFit(longItem, smallVehicle), isNotNull);
      expect(service.checkPhysicalFit(longItem, largeVehicle), isNull);
    });
  });

  group('Volume Calculations', () {
    test('getCapacityInM3 returns correct values', () {
      expect(
        TransportAdvisorService.getCapacityInM3(TransportCapacity.small),
        2.0,
      );
      expect(
        TransportAdvisorService.getCapacityInM3(TransportCapacity.extraLarge),
        40.0,
      );
    });
  });
}
