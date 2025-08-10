import 'dart:convert';
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

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'activityTitle': activityTitle,
      'activityContent': activityContent,
      'activityMedia': activityMedia.map((media) => media.toJson()).toList(),
      'activityCategory': activityCategory,
      'activityMood': activityMood.name,
      'activityDatetime': activityDatetime.toIso8601String(),
      'activityModifiedDate': activityModifiedDate.toIso8601String(),
      'activityStarred': activityStarred,
      'activityProfileId': activityProfileId,
      'activityDone': activityDone,
      'activityNotify': activityNotify,
      'checklist': checklist.map((item) => item.toJson()).toList(),
      'location': location,
      'tags': tags,
      'activityDuration': activityDuration?.inMinutes,
      'reminderTime': reminderTime != null
          ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
          : null,
    };
  }

  String toRawJson() => json.encode(toJson());

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activityId'] ?? '',
      activityTitle: json['activityTitle'] ?? '',
      activityContent: json['activityContent'] ?? '',
      activityMedia:
          (json['activityMedia'] as List<dynamic>?)
              ?.map((media) => ActivityMedia.fromJson(media))
              .toList() ??
          [],
      activityCategory: json['activityCategory'] ?? '',
      activityMood: ActivityMood.values.firstWhere(
        (mood) => mood.name == json['activityMood'],
        orElse: () => ActivityMood.happy,
      ),
      activityDatetime: DateTime.parse(json['activityDatetime']),
      activityModifiedDate: DateTime.parse(json['activityModifiedDate']),
      activityStarred: json['activityStarred'] ?? false,
      activityProfileId: json['activityProfileId'] ?? '',
      activityDone: json['activityDone'] ?? false,
      activityNotify: json['activityNotify'] ?? false,
      checklist:
          (json['checklist'] as List<dynamic>?)
              ?.map((item) => ChecklistItem.fromJson(item))
              .toList() ??
          [],
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      activityDuration: json['activityDuration'] != null
          ? Duration(minutes: json['activityDuration'])
          : null,
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
              hour: json['reminderTime']['hour'],
              minute: json['reminderTime']['minute'],
            )
          : null,
    );
  }

  factory Activity.fromRawJson(String str) =>
      Activity.fromJson(json.decode(str));

  // CopyWith method for updates
  Activity copyWith({
    String? activityId,
    String? activityTitle,
    String? activityContent,
    List<ActivityMedia>? activityMedia,
    String? activityCategory,
    ActivityMood? activityMood,
    DateTime? activityDatetime,
    DateTime? activityModifiedDate,
    bool? activityStarred,
    String? activityProfileId,
    bool? activityDone,
    bool? activityNotify,
    List<ChecklistItem>? checklist,
    String? location,
    List<String>? tags,
    Duration? activityDuration,
    TimeOfDay? reminderTime,
  }) {
    return Activity(
      activityId: activityId ?? this.activityId,
      activityTitle: activityTitle ?? this.activityTitle,
      activityContent: activityContent ?? this.activityContent,
      activityMedia: activityMedia ?? this.activityMedia,
      activityCategory: activityCategory ?? this.activityCategory,
      activityMood: activityMood ?? this.activityMood,
      activityDatetime: activityDatetime ?? this.activityDatetime,
      activityModifiedDate: activityModifiedDate ?? this.activityModifiedDate,
      activityStarred: activityStarred ?? this.activityStarred,
      activityProfileId: activityProfileId ?? this.activityProfileId,
      activityDone: activityDone ?? this.activityDone,
      activityNotify: activityNotify ?? this.activityNotify,
      checklist: checklist ?? this.checklist,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      activityDuration: activityDuration ?? this.activityDuration,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
