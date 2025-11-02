import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? dob;
  final String? country;

  const Profile({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.dob,
    this.country,
  });

  // Factory to create a Profile from a Supabase row (Map)
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      username: map['username'],
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
      dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
      country: map['country'],
    );
  }

  // Method to convert a Profile object into a Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'dob': dob?.toIso8601String(),
      'country': country,
      'updated_at': DateTime.now().toIso8601String(), // Always update this
    };
  }

  // Helper for our BLoC to easily update fields
  Profile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    DateTime? dob,
    String? country,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dob: dob ?? this.dob,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl, dob, country];
}
