import 'package:flutter/material.dart';
import 'package:hello_world/model/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManager extends ChangeNotifier {
  static const String _profilesKey = 'profiles';
  static const String _currentProfileIdKey = 'current_profile_id';

  List<Profile> _profiles = [];
  String? _currentProfileId;
  bool _isLoaded = false; // Track if initial load is complete

  List<Profile> get profiles => _profiles;
  bool get isLoaded => _isLoaded; // Getter for loading state

  /// Safely return the current profile or null
  Profile? get currentProfile {
    if (_profiles.isEmpty) return null;

    return _profiles.firstWhere(
      (p) => p.profileId == _currentProfileId,
      orElse: () => _profiles.first,
    );
  }

  ProfileManager() {
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();

    final profileStrings = prefs.getStringList(_profilesKey) ?? [];
    _profiles = profileStrings.map((str) => Profile.fromRawJson(str)).toList();

    _currentProfileId = prefs.getString(_currentProfileIdKey);

    // Mark as loaded after loading from SharedPreferences
    _isLoaded = true;

    // Don't create Guest profile automatically - let the UI handle empty state
    notifyListeners();
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();

    final profileStrings = _profiles
        .map((profile) => profile.toRawJson())
        .toList();

    await prefs.setStringList(_profilesKey, profileStrings);
    if (_currentProfileId != null) {
      await prefs.setString(_currentProfileIdKey, _currentProfileId!);
    }
  }

  /// Add a new profile
  Future<void> addProfile(Profile profile) async {
    _profiles.add(profile);
    _currentProfileId = profile.profileId;
    await _saveProfiles();
    notifyListeners();
  }

  /// Set current profile by ID
  Future<void> setCurrentProfile(String profileId) async {
    _currentProfileId = profileId;
    await _saveProfiles();
    notifyListeners();
  }

  /// Update profile name
  Future<void> updateProfileName(String profileId, String newName) async {
    final index = _profiles.indexWhere((p) => p.profileId == profileId);
    if (index != -1) {
      final updated = Profile(
        profileId: _profiles[index].profileId,
        profileName: newName,
        profileImage: _profiles[index].profileImage,
      );
      _profiles[index] = updated;
      await _saveProfiles();
      notifyListeners();
    }
  }

  /// Update profile image
  Future<void> updateProfileImage(String profileId, String newImagePath) async {
    final index = _profiles.indexWhere((p) => p.profileId == profileId);
    if (index != -1) {
      final updated = Profile(
        profileId: _profiles[index].profileId,
        profileName: _profiles[index].profileName,
        profileImage: newImagePath,
      );
      _profiles[index] = updated;
      await _saveProfiles();
      notifyListeners();
    }
  }

  /// Delete a profile (only if more than one profile exists)
  Future<bool> deleteProfile(String profileId) async {
    // Prevent deletion if this is the only profile
    if (_profiles.length <= 1) {
      return false; // Deletion not allowed
    }

    _profiles.removeWhere((p) => p.profileId == profileId);
    if (_currentProfileId == profileId) {
      _currentProfileId = _profiles.isNotEmpty
          ? _profiles.first.profileId
          : null;
    }
    await _saveProfiles();
    notifyListeners();
    return true; // Deletion successful
  }
}


// usage
// final profile = Provider.of<ProfileManager>(context).currentProfile;
// await profileManager.updateProfileName(profileId, 'New Name');
// await profileManager.updateProfileImage(profileId, '/path/to/image.jpg');

