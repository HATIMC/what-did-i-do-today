import 'package:flutter/material.dart';
import 'package:hello_world/model/activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityManager extends ChangeNotifier {
  static const String _activitiesKey = 'activities';

  List<Activity> _activities = [];
  bool _isLoaded = false;

  List<Activity> get activities => _activities;
  bool get isLoaded => _isLoaded;

  ActivityManager() {
    _loadActivities();
  }

  /// Load activities from SharedPreferences
  Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();

    final activityStrings = prefs.getStringList(_activitiesKey) ?? [];
    _activities = activityStrings
        .map((str) => Activity.fromRawJson(str))
        .toList();

    // Sort activities by date (newest first)
    _activities.sort(
      (a, b) => b.activityDatetime.compareTo(a.activityDatetime),
    );

    _isLoaded = true;
    notifyListeners();
  }

  /// Save activities to SharedPreferences
  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();

    final activityStrings = _activities
        .map((activity) => activity.toRawJson())
        .toList();

    await prefs.setStringList(_activitiesKey, activityStrings);
  }

  /// Add a new activity
  Future<void> addActivity(Activity activity) async {
    _activities.add(activity);

    // Sort activities by date (newest first)
    _activities.sort(
      (a, b) => b.activityDatetime.compareTo(a.activityDatetime),
    );

    await _saveActivities();
    notifyListeners();
  }

  /// Update an existing activity
  Future<void> updateActivity(Activity updatedActivity) async {
    final index = _activities.indexWhere(
      (a) => a.activityId == updatedActivity.activityId,
    );
    if (index != -1) {
      _activities[index] = updatedActivity.copyWith(
        activityModifiedDate: DateTime.now(),
      );

      // Sort activities by date (newest first)
      _activities.sort(
        (a, b) => b.activityDatetime.compareTo(a.activityDatetime),
      );

      await _saveActivities();
      notifyListeners();
    }
  }

  /// Delete an activity
  Future<void> deleteActivity(String activityId) async {
    _activities.removeWhere((a) => a.activityId == activityId);
    await _saveActivities();
    notifyListeners();
  }

  /// Get activities for a specific date
  List<Activity> getActivitiesForDate(DateTime date) {
    return _activities.where((activity) {
      final activityDate = activity.activityDatetime;
      return activityDate.year == date.year &&
          activityDate.month == date.month &&
          activityDate.day == date.day;
    }).toList();
  }

  /// Get activities for a specific profile
  List<Activity> getActivitiesForProfile(String profileId) {
    return _activities
        .where((activity) => activity.activityProfileId == profileId)
        .toList();
  }

  /// Get activities for a date range
  List<Activity> getActivitiesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _activities.where((activity) {
      final activityDate = activity.activityDatetime;
      return activityDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          activityDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Toggle activity completion status
  Future<void> toggleActivityCompletion(String activityId) async {
    final index = _activities.indexWhere((a) => a.activityId == activityId);
    if (index != -1) {
      final activity = _activities[index];
      _activities[index] = activity.copyWith(
        activityDone: !activity.activityDone,
        activityModifiedDate: DateTime.now(),
      );

      await _saveActivities();
      notifyListeners();
    }
  }

  /// Toggle activity starred status
  Future<void> toggleActivityStar(String activityId) async {
    final index = _activities.indexWhere((a) => a.activityId == activityId);
    if (index != -1) {
      final activity = _activities[index];
      _activities[index] = activity.copyWith(
        activityStarred: !activity.activityStarred,
        activityModifiedDate: DateTime.now(),
      );

      await _saveActivities();
      notifyListeners();
    }
  }

  /// Get activity statistics
  Map<String, int> getActivityStats() {
    return {
      'total': _activities.length,
      'completed': _activities.where((a) => a.activityDone).length,
      'starred': _activities.where((a) => a.activityStarred).length,
      'today': getActivitiesForDate(DateTime.now()).length,
    };
  }

  /// Clear all activities (for development/testing)
  Future<void> clearAllActivities() async {
    _activities.clear();
    await _saveActivities();
    notifyListeners();
  }
}
