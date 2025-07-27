import 'package:hello_world/model/activity_media.dart';

class ChecklistItem {
  final String checklistId;
  final String checklistTitle;
  final String checklistContent;
  final List<ActivityMedia> checklistMedia;

  ChecklistItem({
    required this.checklistId,
    required this.checklistTitle,
    required this.checklistContent,
    required this.checklistMedia,
  });
}
