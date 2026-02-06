import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moving_tool_flutter/core/models/item_dimensions.dart';
import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';

import 'package:moving_tool_flutter/features/transport/presentation/providers/transport_providers.dart';

class TransportMatcherScreen extends ConsumerStatefulWidget {
  const TransportMatcherScreen({super.key});

  @override
  ConsumerState<TransportMatcherScreen> createState() =>
      _TransportMatcherScreenState();
}

class _TransportMatcherScreenState
    extends ConsumerState<TransportMatcherScreen> {
  // Selected Vehicle (Mock list for now, ideally comes from Project)
  TransportResource? _selectedVehicle;

  // Item to check
  ItemDimensions? _currentItem;
  String? _fitResult;
  bool _isAnalyzing = false;
  File? _itemImage;

  final List<TransportResource> _demoVehicles = [
    TransportResource(
      id: 'v1',
      projectId: 'demo',
      name: 'Eigen Auto (Station)',
      type: TransportType.car,
      capacity: TransportCapacity.small, // 120x100x80
      weatherSensitive: true,
      costPerHour: 0,
    ),
    TransportResource(
      id: 'v2',
      projectId: 'demo',
      name: 'Huur Busje (6m³)',
      type: TransportType.van,
      capacity: TransportCapacity.medium, // 250x160x140
      weatherSensitive: false,
      costPerHour: 45,
    ),
    TransportResource(
      id: 'v3',
      projectId: 'demo',
      name: 'Grote Verhuiswagen (18m³)',
      type: TransportType.truck,
      capacity: TransportCapacity.large, // 320x180x190
      weatherSensitive: false,
      costPerHour: 95,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicle = _demoVehicles[1]; // Default to Van
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final item = await picker.pickImage(source: ImageSource.camera);
    if (item == null) return;

    setState(() {
      _itemImage = File(item.path);
      _isAnalyzing = true;
      _fitResult = null;
    });

    try {
      if (mounted) {
        final service = ref.read(transportAdvisorProvider);
        final dimensions = await service.estimateDimensionsFromImage(
          _itemImage!,
        );

        setState(() {
          _currentItem = dimensions;
          _checkFit();
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _fitResult =
              'Fout bij analyseren: ${e.toString().replaceAll('Exception: ', '')}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fout: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkFit() {
    if (_currentItem == null || _selectedVehicle == null) return;

    final service = ref.read(transportAdvisorProvider);
    final issue = service.checkPhysicalFit(_currentItem!, _selectedVehicle!);

    setState(() {
      _fitResult = issue ?? '✅ PAST! (Geen problemen gevonden)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past het? (Transport Matcher)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Select Vehicle
            const Text(
              '1. Kies Voertuig',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<TransportResource>(
              value: _selectedVehicle,
              items: _demoVehicles.map((v) {
                return DropdownMenuItem(
                  value: v,
                  child: Text('${v.name} (${v.capacity.name})'),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedVehicle = v;
                  _checkFit();
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 30),

            // 2. Add Item (Photo)
            const Text(
              '2. Scan Item',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _itemImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_itemImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          Text('Tik om foto te maken'),
                        ],
                      ),
              ),
            ),

            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_currentItem != null && !_isAnalyzing) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Geschatte Afmetingen (AI)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _DimInfo('Hoog', _currentItem!.heightCm),
                          _DimInfo('Breed', _currentItem!.widthCm),
                          _DimInfo('Diep', _currentItem!.depthCm),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '⚠️ Schatting kan afwijken. Meet altijd na.',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // 3. Result
            if (_fitResult != null) ...[
              const Text(
                '3. Resultaat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _fitResult!.startsWith('✅')
                      ? Colors.green[100]
                      : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _fitResult!.startsWith('✅')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _fitResult!.startsWith('✅')
                          ? Icons.check_circle
                          : Icons.warning,
                      color: _fitResult!.startsWith('✅')
                          ? Colors.green
                          : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _fitResult!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DimInfo extends StatelessWidget {
  final String label;
  final double? value;
  const _DimInfo(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          '${value?.toStringAsFixed(0)} cm',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
