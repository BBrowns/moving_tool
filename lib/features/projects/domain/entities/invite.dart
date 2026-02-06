class Invite {
  const Invite({
    required this.id,
    required this.projectId,
    required this.role,
    required this.code,
    required this.expiresAt,
    required this.inviterId,
    this.email,
  });

  final String id;
  final String projectId;
  // We'll define Role in project.dart or a shared file, assuming string or enum for now.
  // Using String to avoid circular deps if Role is in Project, but better to enforce Enum.
  // Let's assume Role is an enum importable from project.dart or user.dart (renaming to project_member.dart suggested).
  final String role;
  final String code;
  final DateTime expiresAt;
  final String inviterId;
  final String? email; // Optional: invite by email

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
