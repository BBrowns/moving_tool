// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/core/services/ai/ai_service.dart';
import 'package:moving_tool_flutter/data/services/database_service.dart';
import 'package:moving_tool_flutter/features/projects/data/models/project_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  /// Exports all data for the current project to a JSON file and shares it
  static Future<void> exportProjectData(
    Project project, {
    bool download = false,
  }) async {
    final jsonString = generateProjectJson(project);
    final fileName =
        'verhuizing_${project.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';

    if (download) {
      await saveToDownloads(jsonString, fileName);
    } else {
      await _shareFile(jsonString, fileName, 'application/json');
    }
  }

  /// Exports expenses to a CSV file for accounting
  static Future<void> exportExpensesCsv(
    Project project, {
    bool download = false,
  }) async {
    final csvString = generateExpensesCsv(project);
    final fileName = 'uitgaven_${project.name.replaceAll(' ', '_')}.csv';

    if (download) {
      await saveToDownloads(csvString, fileName);
    } else {
      await _shareFile(csvString, fileName, 'text/csv');
    }
  }

  static String generateProjectJson(Project project) {
    final data = {
      'project': ProjectModel.fromEntity(project).toJson(),
      'tasks': _jsonList(DatabaseService.getAllTasks()),
      'rooms': _jsonList(DatabaseService.getAllRooms()),
      'boxes': _jsonList(DatabaseService.getAllBoxes()),
      'items': _jsonList(DatabaseService.getAllBoxItems()),
      'shopping': _jsonList(DatabaseService.getAllShoppingItems()),
      'expenses': _jsonList(DatabaseService.getAllExpenses()),
      'journal': _jsonList(DatabaseService.getAllJournalEntries()),
      'notes': _jsonList(DatabaseService.getAllNotes()),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static String generateExpensesCsv(Project project) {
    final expenses = DatabaseService.getAllExpenses();
    final users = project.users;

    final List<List<dynamic>> rows = [];
    rows.add([
      'Datum',
      'Beschrijving',
      'Bedrag',
      'Categorie',
      'Betaald door',
      'Gedeeld met',
    ]);

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final expense in expenses) {
      final payer = users
          .firstWhere(
            (u) => u.id == expense.paidById,
            orElse: () => User(id: '', name: 'Onbekend', color: '#000000'),
          )
          .name;
      final splitNames = expense.splitBetweenIds
          .map((id) {
            return users
                .firstWhere(
                  (u) => u.id == id,
                  orElse: () => User(id: '', name: '?', color: ''),
                )
                .name;
          })
          .join(', ');

      rows.add([
        dateFormat.format(expense.date),
        expense.description,
        expense.amount,
        expense.category.label,
        payer,
        splitNames,
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  /// Exports comprehensive LLM-ready overview
  static Future<void> exportLlmOverview(
    Project project, {
    bool download = false,
  }) async {
    final content = generateLlmOverview(project);
    final fileName = 'ultiem_overzicht_${project.name.replaceAll(' ', '_')}.md';

    if (download) {
      await saveToDownloads(content, fileName);
    } else {
      await _shareFile(content, fileName, 'text/markdown');
    }
  }

  /// Exports LLM overview with AI-generated summary
  static Future<void> exportLlmSummary(
    Project project,
    AIService aiService, {
    bool download = false,
  }) async {
    final overview = generateLlmOverview(project);

    final prompt =
        '''
Je bent een slimme assistent voor een verhuisapp. Analyseer het volgende verhuisoverzicht en stel een uitgebreid rapport op.

Het rapport moet behandelen:
- **Actiepunten**: Wat moet er nog gebeuren
- **Voortgang**: Huidige stand van zaken
- **Knelpunten**: Mogelijke problemen of vertragingen
- **Prioriteiten**: Hoogste prioriteit komende tijd
- **Conclusie**: Algemene observaties

Gebruik koppen en bullets. Schrijf in het Nederlands.

---

$overview

---

Rapport:
''';

    final summary =
        await aiService.generateContent(prompt) ??
        'Kon geen samenvatting genereren.';

    final buffer = StringBuffer();
    buffer.writeln('# 🤖 AI Samenvatting\n');
    buffer.writeln(summary);
    buffer.writeln('\n---\n');
    buffer.writeln(overview);

    final content = buffer.toString();
    final fileName = 'ai_samenvatting_${project.name.replaceAll(' ', '_')}.md';

    if (download) {
      await saveToDownloads(content, fileName);
    } else {
      await _shareFile(content, fileName, 'text/markdown');
    }
  }

  /// Generates a comprehensive markdown overview of the entire project
  static String generateLlmOverview(Project project) {
    final tasks = DatabaseService.getAllTasks();
    final rooms = DatabaseService.getAllRooms();
    final boxes = DatabaseService.getAllBoxes();
    final items = DatabaseService.getAllBoxItems();
    final shopping = DatabaseService.getAllShoppingItems();
    final expenses = DatabaseService.getAllExpenses();
    final journal = DatabaseService.getAllJournalEntries();

    final dateFormat = DateFormat('d MMMM yyyy', 'nl_NL');
    final daysUntil = project.daysUntilMove;

    final buffer = StringBuffer();

    // Header
    buffer.writeln('# ${project.name} - Ultiem Overzicht');
    buffer.writeln();
    buffer.writeln(
      '**Verhuisdatum:** ${dateFormat.format(project.movingDate)} (${daysUntil >= 0 ? "nog $daysUntil dagen" : "voltooid"})',
    );
    buffer.writeln(
      '**Gebruikers:** ${project.users.map((u) => u.name).join(", ")}',
    );
    buffer.writeln('**Gegenereerd:** ${dateFormat.format(DateTime.now())}');
    buffer.writeln();

    // Quick Stats
    buffer.writeln('## 📊 Statistieken');
    buffer.writeln();
    final completedTasks = tasks
        .where((t) => t.status == TaskStatus.done)
        .length;
    final packedBoxes = boxes
        .where(
          (b) => b.status == BoxStatus.packed || b.status == BoxStatus.moved,
        )
        .length;
    final boughtItems = shopping
        .where((s) => s.status == ShoppingStatus.purchased)
        .length;
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    buffer.writeln('| Categorie | Voortgang |');
    buffer.writeln('|-----------|-----------|');
    buffer.writeln('| Taken | $completedTasks/${tasks.length} voltooid |');
    buffer.writeln('| Dozen | $packedBoxes/${boxes.length} ingepakt |');
    buffer.writeln('| Items | ${items.length} totaal |');
    buffer.writeln('| Inkopen | $boughtItems/${shopping.length} gekocht |');
    buffer.writeln(
      '| Uitgaven | €${totalExpenses.toStringAsFixed(2)} totaal |',
    );
    buffer.writeln();

    // Tasks Overview
    buffer.writeln('## ✅ Taken');
    buffer.writeln();
    if (tasks.isEmpty) {
      buffer.writeln('_Geen taken toegevoegd._');
    } else {
      for (final category in TaskCategory.values) {
        final categoryTasks = tasks
            .where((t) => t.category == category)
            .toList();
        if (categoryTasks.isNotEmpty) {
          buffer.writeln('### ${category.label}');
          for (final task in categoryTasks) {
            final check = task.status == TaskStatus.done
                ? '✅'
                : (task.status == TaskStatus.inProgress ? '🔄' : '⬜');
            buffer.writeln('- $check ${task.title}');
          }
          buffer.writeln();
        }
      }
    }

    // Packing Overview
    buffer.writeln('## 📦 Inpakken');
    buffer.writeln();
    if (rooms.isEmpty) {
      buffer.writeln('_Geen kamers toegevoegd._');
    } else {
      for (final room in rooms) {
        final roomBoxes = boxes.where((b) => b.roomId == room.id).toList();
        final packedCount = roomBoxes
            .where((b) => b.status == BoxStatus.packed)
            .length;
        buffer.writeln(
          '### ${room.icon} ${room.name} ($packedCount/${roomBoxes.length} ingepakt)',
        );
        for (final box in roomBoxes) {
          final boxItems = items.where((i) => i.boxId == box.id).toList();
          final status = box.status == BoxStatus.packed ? '✅' : '📦';
          buffer.writeln(
            '- $status **${box.label}**: ${boxItems.map((i) => i.name).join(", ")}',
          );
        }
        buffer.writeln();
      }
    }

    // Shopping Overview
    buffer.writeln('## 🛒 Inkopen');
    buffer.writeln();
    if (shopping.isEmpty) {
      buffer.writeln('_Geen inkopen toegevoegd._');
    } else {
      final tobuy = shopping
          .where((s) => s.status == ShoppingStatus.needed)
          .toList();
      final bought = shopping
          .where((s) => s.status == ShoppingStatus.purchased)
          .toList();
      if (tobuy.isNotEmpty) {
        buffer.writeln('**Nog te kopen:**');
        for (final item in tobuy) {
          buffer.writeln(
            '- ${item.name} (€${item.budgetMax?.toStringAsFixed(2) ?? "?"})',
          );
        }
        buffer.writeln();
      }
      if (bought.isNotEmpty) {
        buffer.writeln('**Gekocht:**');
        for (final item in bought) {
          buffer.writeln('- ✅ ${item.name}');
        }
        buffer.writeln();
      }
    }

    // Expenses Overview
    buffer.writeln('## 💰 Uitgaven');
    buffer.writeln();
    if (expenses.isEmpty) {
      buffer.writeln('_Geen uitgaven geregistreerd._');
    } else {
      buffer.writeln('| Datum | Beschrijving | Bedrag |');
      buffer.writeln('|-------|--------------|--------|');
      for (final expense in expenses.take(20)) {
        buffer.writeln(
          '| ${DateFormat('dd-MM').format(expense.date)} | ${expense.description} | €${expense.amount.toStringAsFixed(2)} |',
        );
      }
      buffer.writeln();
      buffer.writeln('**Totaal: €${totalExpenses.toStringAsFixed(2)}**');
      buffer.writeln();
    }

    // Journal
    buffer.writeln('## 📝 Recente Logboek');
    buffer.writeln();
    if (journal.isEmpty) {
      buffer.writeln('_Geen logboek entries._');
    } else {
      for (final entry in journal.take(10)) {
        buffer.writeln(
          '- ${entry.type.icon} **${entry.title}** - ${DateFormat('dd MMM HH:mm').format(entry.timestamp)}',
        );
        if (entry.description != null && entry.description!.isNotEmpty) {
          buffer.writeln('  > ${entry.description}');
        }
      }
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln(
      '_Dit overzicht is automatisch gegenereerd door Verhuistool._',
    );

    return buffer.toString();
  }

  static Future<void> _shareFile(
    String content,
    String fileName,
    String mimeType,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);

    await Share.shareXFiles([
      XFile(file.path, mimeType: mimeType),
    ], subject: 'Export van verhuizing');
  }

  static Future<String?> saveToDownloads(
    String content,
    String fileName,
  ) async {
    Directory? directory;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return null;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(content);
      debugPrint('File saved to: $path');
      return path;
    } catch (e) {
      debugPrint('Error saving to downloads: $e');
    }
    return null;
  }

  static List<Map<String, dynamic>> _jsonList(List<dynamic> items) {
    return items
        .map((i) => (i as dynamic).toJson() as Map<String, dynamic>)
        .toList();
  }
}
