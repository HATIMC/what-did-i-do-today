import 'dart:convert';

class Profile {
  final String profileId;
  final String profileName;
  final String profileImage; // Can be a path or '' for default avatar

  Profile({
    required this.profileId,
    required this.profileName,
    required this.profileImage,
  });

  /// Create Profile object from a Map (e.g. loaded from JSON)
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      profileId: json['profile_id'] ?? '',
      profileName: json['profile_name'] ?? 'Guest',
      profileImage: json['profile_image'] ?? '',
    );
  }

  /// Convert Profile object to Map
  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'profile_name': profileName,
      'profile_image': profileImage,
    };
  }

  /// Convert Profile to JSON string (optional helper for SharedPreferences)
  String toRawJson() => jsonEncode(toJson());

  /// Create Profile from JSON string (optional helper for SharedPreferences)
  factory Profile.fromRawJson(String str) =>
      Profile.fromJson(jsonDecode(str));
}
