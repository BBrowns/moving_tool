import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_scaffold.dart';
import 'package:moving_tool_flutter/features/assets/domain/entities/asset.dart';
import 'package:moving_tool_flutter/features/assets/presentation/providers/asset_providers.dart';
import 'package:moving_tool_flutter/features/assets/presentation/widgets/asset_card.dart';

class AssetScreen extends ConsumerStatefulWidget {
  const AssetScreen({super.key});

  @override
  ConsumerState<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends ConsumerState<AssetScreen> {
  AssetCategory? _filterCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load assets for default project
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assetsProvider.notifier).loadForProject('default');
    });
  }

  @override
  Widget build(BuildContext context) {
    final allAssets = ref.watch(assetsProvider);
    final totalValue = ref.watch(totalAssetValueProvider);
    final expiringWarranties = ref.watch(expiringWarrantiesProvider);
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 0);

    // Apply filters
    var filteredAssets = allAssets;
    if (_filterCategory != null) {
      filteredAssets = filteredAssets
          .where((a) => a.category == _filterCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredAssets = filteredAssets
          .where(
            (a) =>
                a.name.toLowerCase().contains(query) ||
                (a.brand?.toLowerCase().contains(query) ?? false) ||
                (a.model?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return ResponsiveScaffold(
      title: 'Bezittingen',
      fabHeroTag: 'asset_fab',
      fabLabel: 'Asset',
      fabIcon: Icons.add,
      onFabPressed: () => _showAssetDialog(context, ref),
      actions: [
        if (expiringWarranties.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Badge(
              label: Text('${expiringWarranties.length}'),
              child: IconButton(
                icon: const Icon(Icons.verified_user),
                tooltip: 'Garanties bijna verlopen',
                onPressed: () =>
                    _showWarrantyAlert(context, expiringWarranties),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Chip(
            avatar: const Icon(Icons.euro, size: 16),
            label: Text(currencyFormat.format(totalValue)),
          ),
        ),
      ],
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Zoeken...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      filled: true,
                      fillColor: context.colors.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<AssetCategory?>(
                  icon: Badge(
                    isLabelVisible: _filterCategory != null,
                    child: const Icon(Icons.filter_list),
                  ),
                  tooltip: 'Filter op categorie',
                  onSelected: (v) => setState(() => _filterCategory = v),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('Alle categorieën'),
                    ),
                    const PopupMenuDivider(),
                    ...AssetCategory.values.map(
                      (c) => PopupMenuItem(value: c, child: Text(c.label)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category summary chips (horizontal scroll)
          if (_filterCategory == null)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: AssetCategory.values.map((category) {
                  final count = allAssets
                      .where((a) => a.category == category)
                      .length;
                  if (count == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text('${category.label} ($count)'),
                      onPressed: () =>
                          setState(() => _filterCategory = category),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 8),

          // Asset list
          Expanded(
            child: filteredAssets.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredAssets.length,
                    itemBuilder: (context, index) {
                      final asset = filteredAssets[index];
                      return AssetCard(
                            asset: asset,
                            onTap: () =>
                                _showAssetDialog(context, ref, asset: asset),
                            onDelete: () => ref
                                .read(assetsProvider.notifier)
                                .delete(asset.id),
                          )
                          .animate()
                          .fade(duration: 300.ms, delay: (index * 50).ms)
                          .slideX(begin: -0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text('Nog geen bezittingen', style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Voeg items toe om ze te tracken',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showWarrantyAlert(BuildContext context, List<Asset> assets) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.warning),
            SizedBox(width: 8),
            Text('Garanties verlopen'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              final days = asset.warrantyExpiry!
                  .difference(DateTime.now())
                  .inDays;
              return ListTile(
                title: Text(asset.name),
                subtitle: Text('Nog $days dagen'),
                leading: Icon(
                  Icons.verified_user,
                  color: days > 7 ? AppTheme.warning : AppTheme.error,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  void _showAssetDialog(BuildContext context, WidgetRef ref, {Asset? asset}) {
    final isEditing = asset != null;
    final nameController = TextEditingController(text: asset?.name);
    final brandController = TextEditingController(text: asset?.brand);
    final modelController = TextEditingController(text: asset?.model);
    final priceController = TextEditingController(
      text: asset?.purchasePrice?.toStringAsFixed(0),
    );
    final notesController = TextEditingController(text: asset?.notes);

    AssetCategory? category = asset?.category;
    DateTime purchaseDate = asset?.purchaseDate ?? DateTime.now();
    DateTime? warrantyExpiry = asset?.warrantyExpiry;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      isEditing ? 'Bezitting bewerken' : 'Nieuwe bezitting',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isEditing)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.error,
                        ),
                        onPressed: () {
                          ref.read(assetsProvider.notifier).delete(asset.id);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                TextField(
                  controller: nameController,
                  autofocus: !isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Naam *',
                    hintText: 'Bijv. Samsung TV 55"',
                  ),
                ),
                const SizedBox(height: 12),

                // Brand & Model row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: brandController,
                        decoration: const InputDecoration(
                          labelText: 'Merk',
                          hintText: 'Samsung',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: modelController,
                        decoration: const InputDecoration(
                          labelText: 'Model',
                          hintText: 'QN55Q80A',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Category
                DropdownButtonFormField<AssetCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categorie'),
                  items: AssetCategory.values
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => category = v),
                ),
                const SizedBox(height: 12),

                // Price
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Aankoopprijs (€)',
                    prefixIcon: Icon(Icons.euro),
                  ),
                ),
                const SizedBox(height: 12),

                // Purchase date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Aankoopdatum'),
                  subtitle: Text(
                    DateFormat('d MMMM yyyy').format(purchaseDate),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: purchaseDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => purchaseDate = picked);
                  },
                ),

                // Warranty expiry
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Garantie tot'),
                  subtitle: Text(
                    warrantyExpiry != null
                        ? DateFormat('d MMMM yyyy').format(warrantyExpiry!)
                        : 'Niet ingesteld',
                  ),
                  trailing: warrantyExpiry != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              setState(() => warrantyExpiry = null),
                        )
                      : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          warrantyExpiry ??
                          purchaseDate.add(const Duration(days: 365)),
                      firstDate: purchaseDate,
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => warrantyExpiry = picked);
                  },
                ),
                const SizedBox(height: 12),

                // Notes
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notities',
                    hintText: 'Extra informatie...',
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) return;

                    final price = double.tryParse(priceController.text);

                    if (isEditing) {
                      ref
                          .read(assetsProvider.notifier)
                          .update(
                            asset.copyWith(
                              name: nameController.text,
                              brand: brandController.text.isEmpty
                                  ? null
                                  : brandController.text,
                              model: modelController.text.isEmpty
                                  ? null
                                  : modelController.text,
                              category: category,
                              purchasePrice: price,
                              currentValue: price,
                              purchaseDate: purchaseDate,
                              warrantyExpiry: warrantyExpiry,
                              notes: notesController.text.isEmpty
                                  ? null
                                  : notesController.text,
                            ),
                          );
                    } else {
                      ref
                          .read(assetsProvider.notifier)
                          .add(
                            projectId: 'default',
                            name: nameController.text,
                            brand: brandController.text.isEmpty
                                ? null
                                : brandController.text,
                            model: modelController.text.isEmpty
                                ? null
                                : modelController.text,
                            category: category,
                            purchasePrice: price,
                            purchaseDate: purchaseDate,
                            warrantyExpiry: warrantyExpiry,
                            notes: notesController.text.isEmpty
                                ? null
                                : notesController.text,
                          );
                    }
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Opslaan' : 'Toevoegen'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
