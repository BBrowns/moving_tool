import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/admin_vault/domain/entities/metric_log.dart';
import 'package:moving_tool_flutter/features/admin_vault/domain/entities/service_contract.dart';
import 'package:moving_tool_flutter/features/admin_vault/presentation/providers/admin_vault_providers.dart';

/// Admin Vault screen for managing contracts, metrics, and documents.
class AdminVaultScreen extends ConsumerStatefulWidget {
  const AdminVaultScreen({super.key});

  @override
  ConsumerState<AdminVaultScreen> createState() => _AdminVaultScreenState();
}

class _AdminVaultScreenState extends ConsumerState<AdminVaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsProvider);
    final metricsAsync = ref.watch(metricsProvider);
    final totalCosts = ref.watch(totalMonthlyCostsProvider);
    final urgentCount = ref.watch(urgentContractsProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Vault'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Badge(
                isLabelVisible: urgentCount > 0,
                label: Text('$urgentCount'),
                child: const Icon(Icons.description_rounded),
              ),
              text: 'Contracten',
            ),
            const Tab(icon: Icon(Icons.show_chart), text: 'Metingen'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
            tooltip: 'Toevoegen',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contracts Tab
          _ContractsTab(contractsAsync: contractsAsync, totalCosts: totalCosts),
          // Metrics Tab
          _MetricsTab(metricsAsync: metricsAsync),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final isContractTab = _tabController.index == 0;

    if (isContractTab) {
      _showAddContractDialog(context);
    } else {
      _showAddMetricDialog(context);
    }
  }

  void _showAddContractDialog(BuildContext context) {
    ContractType selectedType = ContractType.internet;
    final providerController = TextEditingController();
    final costController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime? endDate;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Contract Toevoegen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ContractType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ContractType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [
                              Icon(t.icon, size: 20),
                              const SizedBox(width: 8),
                              Text(t.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: providerController,
                  decoration: const InputDecoration(
                    labelText: 'Aanbieder',
                    hintText: 'bijv. Ziggo, Vattenfall',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: costController,
                  decoration: const InputDecoration(
                    labelText: 'Maandkosten (€)',
                    prefixText: '€ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Startdatum'),
                  subtitle: Text(DateFormat('dd-MM-yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) setState(() => startDate = date);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Einddatum (optioneel)'),
                  subtitle: Text(
                    endDate != null
                        ? DateFormat('dd-MM-yyyy').format(endDate!)
                        : 'Geen einddatum',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          endDate ?? startDate.add(const Duration(days: 365)),
                      firstDate: startDate,
                      lastDate: DateTime(2035),
                    );
                    setState(() => endDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleer'),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(contractsProvider.notifier)
                    .addContract(
                      type: selectedType,
                      provider: providerController.text.isEmpty
                          ? selectedType.label
                          : providerController.text,
                      startDate: startDate,
                      endDate: endDate,
                      monthlyCost: double.tryParse(costController.text),
                    );
                Navigator.pop(context);
              },
              child: const Text('Toevoegen'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMetricDialog(BuildContext context) {
    MetricType selectedType = MetricType.internetSpeed;
    final valueController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Meting Toevoegen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<MetricType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: MetricType.values
                    .where((t) => t != MetricType.custom)
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: 'Waarde',
                  suffixText: selectedType.unit,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleer'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(valueController.text);
                if (value == null) return;

                ref
                    .read(metricsProvider.notifier)
                    .addMetric(type: selectedType, value: value);
                Navigator.pop(context);
              },
              child: const Text('Toevoegen'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Contracts Tab
// ============================================================================

class _ContractsTab extends StatelessWidget {
  const _ContractsTab({required this.contractsAsync, required this.totalCosts});

  final AsyncValue<List<ServiceContract>> contractsAsync;
  final double totalCosts;

  @override
  Widget build(BuildContext context) {
    return contractsAsync.when(
      data: (contracts) {
        if (contracts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text('Geen contracten', style: context.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Voeg je eerste contract toe',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Actief',
                      value: '${contracts.where((c) => c.isActive).length}',
                      icon: Icons.check_circle,
                      color: AppTheme.success,
                    ),
                    _SummaryItem(
                      label: 'Maandkosten',
                      value: '€${totalCosts.toStringAsFixed(0)}',
                      icon: Icons.euro,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 16),

            // Contract List
            ...contracts
                .map((contract) => _ContractCard(contract: contract))
                .toList()
                .animate(interval: 50.ms)
                .fadeIn()
                .slideX(begin: 0.05),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Fout: $err')),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ContractCard extends ConsumerWidget {
  const _ContractCard({required this.contract});

  final ServiceContract contract;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrgent = contract.isDeadlineApproaching;

    return Card(
      color: isUrgent ? AppTheme.warning.withValues(alpha: 0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUrgent
              ? AppTheme.warning.withValues(alpha: 0.2)
              : context.colors.primaryContainer,
          child: Icon(
            contract.type.icon,
            color: isUrgent ? AppTheme.warning : context.colors.primary,
          ),
        ),
        title: Text(contract.provider),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contract.type.label),
            if (contract.monthlyCost != null)
              Text('€${contract.monthlyCost!.toStringAsFixed(2)}/maand'),
            if (isUrgent)
              Text(
                '⚠️ Opzeggen voor ${DateFormat('dd-MM').format(contract.cancelByDate!)}',
                style: TextStyle(
                  color: AppTheme.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            ref.read(contractsProvider.notifier).deleteContract(contract.id);
          },
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ============================================================================
// Metrics Tab
// ============================================================================

class _MetricsTab extends StatelessWidget {
  const _MetricsTab({required this.metricsAsync});

  final AsyncValue<List<MetricLog>> metricsAsync;

  @override
  Widget build(BuildContext context) {
    return metricsAsync.when(
      data: (metrics) {
        if (metrics.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  size: 64,
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text('Geen metingen', style: context.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Log je eerste meting',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        // Group metrics by type
        final groupedMetrics = <MetricType, List<MetricLog>>{};
        for (final metric in metrics) {
          groupedMetrics.putIfAbsent(metric.type, () => []).add(metric);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: groupedMetrics.entries
              .map(
                (entry) =>
                    _MetricChartCard(type: entry.key, metrics: entry.value),
              )
              .toList()
              .animate(interval: 100.ms)
              .fadeIn()
              .slideY(begin: 0.05),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Fout: $err')),
    );
  }
}

class _MetricChartCard extends StatelessWidget {
  const _MetricChartCard({required this.type, required this.metrics});

  final MetricType type;
  final List<MetricLog> metrics;

  @override
  Widget build(BuildContext context) {
    final sortedMetrics = [...metrics]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final spots = sortedMetrics.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final latestValue = sortedMetrics.isNotEmpty ? sortedMetrics.last.value : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.label,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${latestValue.toStringAsFixed(1)} ${type.unit}',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: spots.length < 2
                  ? Center(
                      child: Text(
                        'Voeg meer metingen toe voor grafiek',
                        style: context.textTheme.bodySmall,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: context.colors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: context.colors.primary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
