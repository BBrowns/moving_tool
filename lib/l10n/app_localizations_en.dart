// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Moving Tool';

  @override
  String get packingTab => 'Packing';

  @override
  String get projectsTab => 'Projects';

  @override
  String get settingsTab => 'Settings';

  @override
  String get addProject => 'Add Project';

  @override
  String get editProject => 'Edit Project';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String get members => 'Members';

  @override
  String get transport => 'Transport';

  @override
  String get expenses => 'Expenses';

  @override
  String get tasks => 'Tasks';

  @override
  String get helloWorld => 'Hello World!';
}
