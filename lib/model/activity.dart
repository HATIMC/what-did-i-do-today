import 'package:flutter/material.dart';
import 'package:hello_world/model/activity_media.dart';
import 'package:hello_world/model/checklist.dart';
import 'package:hello_world/model/enum/mood.dart';

class Activity {
  final String activityId;
  final String activityTitle;
  final String activityContent;
  final List<ActivityMedia> activityMedia;
  final String activityCategory;
  final ActivityMood activityMood;
  final DateTime activityDatetime;
  final DateTime activityModifiedDate;
  final bool activityStarred;
  final String activityProfileId;
  final bool activityDone;
  final bool activityNotify;
  final List<ChecklistItem> checklist;

  // New fields
  final String? location;
  final List<String> tags;
  final Duration? activityDuration;
  final TimeOfDay? reminderTime;

  Activity({
    required this.activityId,
    required this.activityTitle,
    required this.activityContent,
    required this.activityMedia,
    required this.activityCategory,
    required this.activityMood,
    required this.activityDatetime,
    required this.activityModifiedDate,
    required this.activityStarred,
    required this.activityProfileId,
    required this.activityDone,
    required this.activityNotify,
    required this.checklist,
    this.location,
    this.tags = const [],
    this.activityDuration,
    this.reminderTime,
  });
}
