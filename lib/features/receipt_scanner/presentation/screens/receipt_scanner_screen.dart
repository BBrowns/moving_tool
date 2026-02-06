// Receipt Scanner Screen - Camera/gallery OCR interface
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/receipt_scanner/data/services/ocr_service.dart';
import 'package:moving_tool_flutter/features/receipt_scanner/domain/models/receipt_data.dart';

/// Receipt Scanner screen with camera and gallery options
class ReceiptScannerScreen extends ConsumerStatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  ConsumerState<ReceiptScannerScreen> createState() =>
      _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends ConsumerState<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  File? _selectedImage;
  ReceiptData? _scannedData;
  String? _error;

  @override
  void dispose() {
    OcrService.instance.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isProcessing = true;
        _error = null;
        _scannedData = null;
      });

      // Process with OCR
      final receiptData = await OcrService.instance.scanReceipt(
        _selectedImage!,
      );

      setState(() {
        _scannedData = receiptData;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Fout bij verwerken: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Scanner'),
        actions: [
          if (_scannedData != null && _scannedData!.hasMinimumData)
            TextButton.icon(
              onPressed: _createAsset,
              icon: const Icon(Icons.add),
              label: const Text('Maak Asset'),
            ),
        ],
      ),
      body: _selectedImage == null ? _buildPickerView() : _buildResultView(),
    );
  }

  Widget _buildPickerView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: context.colors.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Scan een bon',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maak een foto of kies uit je galerij',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: _OptionCard(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          color: const Color(0xFF2196F3),
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _OptionCard(
                          icon: Icons.photo_library,
                          label: 'Galerij',
                          color: const Color(0xFF9C27B0),
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.offline_bolt, color: context.colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tekst wordt lokaal verwerkt - geen internet nodig',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
                .animate(interval: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    onPressed: () => setState(() {
                      _selectedImage = null;
                      _scannedData = null;
                      _error = null;
                    }),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Processing indicator
          if (_isProcessing) ...[
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Verwerken met ML Kit...',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          // Error message
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_error!)),
                ],
              ),
            ),
          ],

          // Results
          if (_scannedData != null) ...[_buildResultCard()],
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final data = _scannedData!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Confidence indicator
            Row(
              children: [
                Icon(
                  data.confidence > 0.7 ? Icons.check_circle : Icons.info,
                  color: data.confidence > 0.7 ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Betrouwbaarheid: ${(data.confidence * 100).toInt()}%',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: data.confidence > 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Store name
            if (data.storeName != null) ...[
              _ResultRow(
                icon: Icons.store,
                label: 'Winkel',
                value: data.storeName!,
                onEdit: () => _editValue('storeName'),
              ),
              const SizedBox(height: 12),
            ],

            // Date
            if (data.date != null) ...[
              _ResultRow(
                icon: Icons.calendar_today,
                label: 'Datum',
                value:
                    '${data.date!.day}-${data.date!.month}-${data.date!.year}',
                onEdit: () => _editValue('date'),
              ),
              const SizedBox(height: 12),
            ],

            // Total
            if (data.totalAmount != null) ...[
              _ResultRow(
                icon: Icons.euro,
                label: 'Totaal',
                value: '€${data.totalAmount!.toStringAsFixed(2)}',
                isHighlighted: true,
                onEdit: () => _editValue('total'),
              ),
              const SizedBox(height: 12),
            ],

            // Items
            if (data.items.isNotEmpty) ...[
              const Divider(),
              Text(
                'Items (${data.items.length})',
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...data.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item.name)),
                      if (item.price != null)
                        Text(
                          '€${item.price!.toStringAsFixed(2)}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            // Raw text toggle
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Raw OCR tekst'),
              tilePadding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    data.rawText,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editValue(String field) {
    // TODO: Show edit dialog for manual correction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bewerken komt binnenkort...')),
    );
  }

  void _createAsset() {
    if (_scannedData == null) return;

    // Navigate to asset creation with pre-filled data
    // TODO: Pass data to asset creation screen
    context.push(
      '/assets',
      extra: {
        'storeName': _scannedData!.storeName,
        'purchaseDate': _scannedData!.date,
        'price': _scannedData!.totalAmount,
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isHighlighted ? const EdgeInsets.all(12) : null,
      decoration: isHighlighted
          ? BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18),
            tooltip: 'Bewerken',
          ),
        ],
      ),
    );
  }
}
