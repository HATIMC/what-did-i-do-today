import 'dart:convert';
import 'package:hello_world/model/activity_media.dart';

class ChecklistItem {
  final String checklistId;
  final String checklistTitle;
  final String checklistContent;
  final List<ActivityMedia> checklistMedia;
  final bool isChecked;

  ChecklistItem({
    required this.checklistId,
    required this.checklistTitle,
    required this.checklistContent,
    required this.checklistMedia,
    this.isChecked = false,
  });

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'checklistId': checklistId,
      'checklistTitle': checklistTitle,
      'checklistContent': checklistContent,
      'checklistMedia': checklistMedia.map((media) => media.toJson()).toList(),
      'isChecked': isChecked,
    };
  }

  String toRawJson() => json.encode(toJson());

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      checklistId: json['checklistId'] ?? '',
      checklistTitle: json['checklistTitle'] ?? '',
      checklistContent: json['checklistContent'] ?? '',
      checklistMedia:
          (json['checklistMedia'] as List<dynamic>?)
              ?.map((media) => ActivityMedia.fromJson(media))
              .toList() ??
          [],
      isChecked: json['isChecked'] ?? false,
    );
  }

  factory ChecklistItem.fromRawJson(String str) =>
      ChecklistItem.fromJson(json.decode(str));

  ChecklistItem copyWith({
    String? checklistId,
    String? checklistTitle,
    String? checklistContent,
    List<ActivityMedia>? checklistMedia,
    bool? isChecked,
  }) {
    return ChecklistItem(
      checklistId: checklistId ?? this.checklistId,
      checklistTitle: checklistTitle ?? this.checklistTitle,
      checklistContent: checklistContent ?? this.checklistContent,
      checklistMedia: checklistMedia ?? this.checklistMedia,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
