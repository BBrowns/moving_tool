import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/assets/domain/entities/asset.dart';
import 'package:intl/intl.dart';

/// Card widget displaying a single asset with key info
class AssetCard extends StatelessWidget {
  const AssetCard({
    required this.asset,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final Asset asset;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM yyyy');
    final daysUntilWarrantyExpiry = asset.warrantyExpiry != null
        ? asset.warrantyExpiry!.difference(DateTime.now()).inDays
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _categoryColor(
                        asset.category,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcon(asset.category),
                      color: _categoryColor(asset.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and brand
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (asset.brand != null || asset.model != null)
                          Text(
                            [
                              asset.brand,
                              asset.model,
                            ].whereType<String>().join(' '),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Value
                  if (asset.currentValue != null)
                    Text(
                      currencyFormat.format(asset.currentValue),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Info chips row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Purchase date
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: dateFormat.format(asset.purchaseDate),
                  ),

                  // Category
                  if (asset.category != null)
                    _InfoChip(
                      icon: _categoryIcon(asset.category),
                      label: asset.category!.label,
                      color: _categoryColor(asset.category),
                    ),

                  // Warranty status
                  if (daysUntilWarrantyExpiry != null)
                    _InfoChip(
                      icon: Icons.verified_user,
                      label: daysUntilWarrantyExpiry > 0
                          ? '$daysUntilWarrantyExpiry dagen'
                          : 'Verlopen',
                      color: daysUntilWarrantyExpiry > 30
                          ? AppTheme.success
                          : daysUntilWarrantyExpiry > 0
                          ? AppTheme.warning
                          : AppTheme.error,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(AssetCategory? category) {
    switch (category) {
      case AssetCategory.furniture:
        return Icons.chair;
      case AssetCategory.electronics:
        return Icons.devices;
      case AssetCategory.appliances:
        return Icons.kitchen;
      case AssetCategory.decor:
        return Icons.palette;
      case AssetCategory.storage:
        return Icons.inventory_2;
      case AssetCategory.outdoor:
        return Icons.park;
      case AssetCategory.lighting:
        return Icons.lightbulb;
      case AssetCategory.textiles:
        return Icons.curtains;
      case AssetCategory.kitchenware:
        return Icons.restaurant;
      case AssetCategory.bathroom:
        return Icons.bathtub;
      case AssetCategory.tools:
        return Icons.build;
      case AssetCategory.other:
      case null:
        return Icons.category;
    }
  }

  Color _categoryColor(AssetCategory? category) {
    switch (category) {
      case AssetCategory.furniture:
        return Colors.brown;
      case AssetCategory.electronics:
        return Colors.blue;
      case AssetCategory.appliances:
        return Colors.teal;
      case AssetCategory.decor:
        return Colors.purple;
      case AssetCategory.storage:
        return Colors.orange;
      case AssetCategory.outdoor:
        return Colors.green;
      case AssetCategory.lighting:
        return Colors.amber;
      case AssetCategory.textiles:
        return Colors.pink;
      case AssetCategory.kitchenware:
        return Colors.red;
      case AssetCategory.bathroom:
        return Colors.cyan;
      case AssetCategory.tools:
        return Colors.grey;
      case AssetCategory.other:
      case null:
        return AppTheme.primary;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? context.colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
