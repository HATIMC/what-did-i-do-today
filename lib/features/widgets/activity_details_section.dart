import 'package:flutter/material.dart';
import 'date_time_picker.dart';
import 'location_input.dart';
import 'duration_picker.dart';
import 'tags_input.dart';
import 'checklist_input.dart';
import 'attachments_input.dart';
import '../../model/checklist.dart';
import '../../model/activity_media.dart';

class ActivityDetailsSection extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final TextEditingController locationController;
  final int durationHours;
  final int durationMinutes;
  final TextEditingController tagsController;
  final List<String> tags;
  final List<ChecklistItem> checklist;
  final List<ActivityMedia> attachments;
  final Function(DateTime) onDateChanged;
  final Function(TimeOfDay) onTimeChanged;
  final Function(int hours, int minutes) onDurationChanged;
  final Function(String) onTagAdded;
  final Function(String) onTagRemoved;
  final Function(List<ChecklistItem>) onChecklistChanged;
  final Function(List<ActivityMedia>) onAttachmentsChanged;

  const ActivityDetailsSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.locationController,
    required this.durationHours,
    required this.durationMinutes,
    required this.tagsController,
    required this.tags,
    required this.checklist,
    required this.attachments,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onDurationChanged,
    required this.onTagAdded,
    required this.onTagRemoved,
    required this.onChecklistChanged,
    required this.onAttachmentsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('moreDetailsInput'),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Time Row
          DateTimePicker(
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            onDateChanged: onDateChanged,
            onTimeChanged: onTimeChanged,
          ),
          const SizedBox(height: 16),

          // Location and Duration Row
          Row(
            children: [
              Expanded(child: LocationInput(controller: locationController)),
              const SizedBox(width: 12),
              Expanded(
                child: DurationPicker(
                  durationHours: durationHours,
                  durationMinutes: durationMinutes,
                  onDurationChanged: onDurationChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tags Input
          TagsInput(
            controller: tagsController,
            tags: tags,
            onTagAdded: onTagAdded,
            onTagRemoved: onTagRemoved,
          ),
          const SizedBox(height: 16),

          // Checklist Input
          ChecklistInput(
            checklist: checklist,
            onChecklistChanged: onChecklistChanged,
          ),
          const SizedBox(height: 16),

          // Attachments Input
          AttachmentsInput(
            attachments: attachments,
            onAttachmentsChanged: onAttachmentsChanged,
          ),
        ],
      ),
    );
  }
}
