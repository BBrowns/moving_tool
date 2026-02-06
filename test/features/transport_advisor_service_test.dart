import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:moving_tool_flutter/core/models/item_dimensions.dart';
import 'package:moving_tool_flutter/features/transport/application/transport_advisor_service.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';

import 'transport_advisor_service_test_mocks.mocks.dart';

void main() {
  late TransportAdvisorService service;
  late MockAIService mockAIService;

  setUp(() {
    mockAIService = MockAIService();
    service = TransportAdvisorService(aiService: mockAIService);
  });

  group('TransportAdvisorService AI Logic', () {
    test(
      'estimateDimensionsFromImage throws Exception if AI Service is null',
      () async {
        final serviceNoAI = TransportAdvisorService(aiService: null);
        expect(
          () => serviceNoAI.estimateDimensionsFromImage(File('test_image.jpg')),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'estimateDimensionsFromImage returns correct dimensions on valid JSON',
      () async {
        when(mockAIService.generateContentFromImage(any, any)).thenAnswer(
          (_) async =>
              '{"height": 100, "width": 50, "depth": 30, "weight": 20}',
        );

        final result = await service.estimateDimensionsFromImage(
          File('img.jpg'),
        );

        expect(result, isNotNull);
        expect(result!.heightCm, 100);
        expect(result.widthCm, 50);
        expect(result.depthCm, 30);
        expect(result.weightKg, 20);
      },
    );

    test('estimateDimensionsFromImage handles markdown code blocks', () async {
      when(mockAIService.generateContentFromImage(any, any)).thenAnswer(
        (_) async =>
            '```json\n{"height": 100, "width": 50, "depth": 30, "weight": 20}\n```',
      );

      final result = await service.estimateDimensionsFromImage(File('img.jpg'));

      expect(result, isNotNull);
      expect(result!.heightCm, 100);
    });

    test(
      'estimateDimensionsFromImage throws Exception on malformed JSON',
      () async {
        when(
          mockAIService.generateContentFromImage(any, any),
        ).thenAnswer((_) async => 'I think it is about 1 meter high.');

        expect(
          () => service.estimateDimensionsFromImage(File('img.jpg')),
          throwsA(isA<Exception>()),
        );
      },
    );
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
