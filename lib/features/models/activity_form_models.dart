import 'package:flutter/material.dart';
import '../../model/checklist.dart';
import '../../model/activity_media.dart';
import '../../model/profile.dart';
import '../../model/enum/mood.dart';

class ActivityFormData {
  final String title;
  final String description;
  final String location;
  final String category;
  final DateTime? date;
  final TimeOfDay? time;
  final int durationHours;
  final int durationMinutes;
  final List<String> tags;
  final bool isImportant;
  final bool isCompleted;
  final List<ChecklistItem> checklist;
  final List<ActivityMedia> attachments;
  final Profile? selectedProfile;
  final ActivityMood mood;

  const ActivityFormData({
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.date,
    required this.time,
    required this.durationHours,
    required this.durationMinutes,
    required this.tags,
    required this.isImportant,
    required this.isCompleted,
    required this.checklist,
    required this.attachments,
    this.selectedProfile,
    this.mood = ActivityMood.happy,
  });

  bool get isValid {
    return title.trim().isNotEmpty &&
        date != null &&
        time != null &&
        category.isNotEmpty &&
        selectedProfile != null;
  }
}

class ActivityFormValidation {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an activity title';
    }
    return null;
  }

  static bool isFormValid(ActivityFormData data) {
    return data.isValid;
  }
}

class ActivityFormUtils {
  static void showValidationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  static void showSuccessMessage(BuildContext context, ActivityFormData data) {
    String statusText = '';
    if (data.isImportant && data.isCompleted) {
      statusText = ' (Important & Completed)';
    } else if (data.isImportant) {
      statusText = ' (Important)';
    } else if (data.isCompleted) {
      statusText = ' (Completed)';
    }

    String profileText = data.selectedProfile != null
        ? ' for ${data.selectedProfile!.profileName}'
        : '';

    String moodText = ' ${data.mood.emoji}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Activity "${data.title}"$statusText$profileText$moodText saved!',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
