import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class AuthService {
  // Mock current user
  // In real app, this would come from Supabase/Firebase Auth
  UserProfile? _currentUser;

  AuthService() {
    // Auto-login as "Ik" (Admin) for dev
    _currentUser = const UserProfile(
      id: 'user_1',
      name: 'Ik',
      email: 'ik@example.com',
    );
  }

  UserProfile? get currentUser => _currentUser;

  String? get currentUserId => _currentUser?.id;

  Future<void> login(String email, String password) async {
    // Mock login
    if (email == 'vriend@example.com') {
      _currentUser = const UserProfile(
        id: 'user_2',
        name: 'Vriend',
        email: 'vriend@example.com',
      );
    } else {
      _currentUser = const UserProfile(
        id: 'user_1',
        name: 'Ik',
        email: 'ik@example.com',
      );
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});
