class UserEntity {
  final String id;
  final String email; // Required (primary identifier)
  final String? phone;
  final String? name;
  final String? username;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? country;
  final List<String> linkedProviders; // e.g. ["google", "facebook"]

  UserEntity({
    required this.id,
    required this.email,
    this.phone,
    this.name,
    this.username,
    this.avatarUrl,
    this.dateOfBirth,
    this.country,
    required this.linkedProviders,
  });
}
