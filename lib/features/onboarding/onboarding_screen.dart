// Onboarding Screen - First-run setup
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moving_tool_flutter/core/models/models.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/data/providers/providers.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  
  // Form data
  final _nameController = TextEditingController();
  final _user1Controller = TextEditingController();
  final _user2Controller = TextEditingController();
  DateTime _movingDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    // Check if we have existing projects to skip welcome screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projects = ref.read(projectsProvider);
      if (projects.isNotEmpty) {
        setState(() => _currentPage = 1);
        _pageController.jumpToPage(1);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _user1Controller.dispose();
    _user2Controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    final projects = ref.read(projectsProvider);
    // If we have projects (skipping welcome), don't go back to page 0
    if (_currentPage > (projects.isNotEmpty ? 1 : 0)) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final uuid = const Uuid();
      
      // Create users
      final users = <User>[];
      if (_user1Controller.text.isNotEmpty) {
        users.add(User(
          id: uuid.v4(),
          name: _user1Controller.text,
          color: '#6366F1',
        ));
      }
      if (_user2Controller.text.isNotEmpty) {
        users.add(User(
          id: uuid.v4(),
          name: _user2Controller.text,
          color: '#8B5CF6',
        ));
      }
      
      // Create project
      final project = Project(
        id: uuid.v4(),
        name: _nameController.text.isEmpty ? 'Mijn Verhuizing' : _nameController.text,
        movingDate: _movingDate,
        fromAddress: Address(),
        toAddress: Address(),
        users: users,
        createdAt: DateTime.now(),
      );
      
      // Save project and update both providers
      if (!mounted) return;
      await ref.read(projectProvider.notifier).save(project);
      
      if (!mounted) return;
      await ref.read(projectProvider.notifier).setActive(project.id);
      
      if (!mounted) return;
      ref.read(projectsProvider.notifier).load(); // Refresh projects list
      
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final hasProjects = projects.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Close button for existing users
            if (hasProjects)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/projects');
                        }
                      },
                      icon: const Icon(Icons.close),
                      tooltip: 'Annuleren',
                    ),
                  ],
                ),
              ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(3, (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index <= _currentPage 
                          ? AppTheme.primary 
                          : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swiping back to welcome if skipped
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildProjectPage(),
                  _buildUsersPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > (hasProjects ? 1 : 0))
                    OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Terug'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _currentPage == 2 ? _completeOnboarding : _nextPage,
                    child: Text(_currentPage == 2 ? 'Starten!' : 'Volgende'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📦', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            'Welkom bij Verhuistool',
            style: context.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Jouw persoonlijke assistent voor een stressvrije verhuizing',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Info',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Geef je verhuizing een naam en kies de datum',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Naam van je verhuizing',
              hintText: 'bijv. Verhuizing Amsterdam',
              prefixIcon: Icon(Icons.home_rounded),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month_rounded),
            title: const Text('Verhuisdatum'),
            subtitle: Text(
              '${_movingDate.day}-${_movingDate.month}-${_movingDate.year}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _movingDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _movingDate = date);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wie verhuist er?',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voeg de namen toe van de personen die mee verhuizen',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _user1Controller,
            decoration: const InputDecoration(
              labelText: 'Persoon 1',
              hintText: 'Naam',
              prefixIcon: Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _user2Controller,
            decoration: const InputDecoration(
              labelText: 'Persoon 2 (optioneel)',
              hintText: 'Naam',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
