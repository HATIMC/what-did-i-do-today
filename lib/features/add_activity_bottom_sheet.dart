import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'widgets/activity_form_header.dart';
import 'widgets/activity_text_field.dart';
import 'widgets/activity_details_section.dart';
import 'widgets/activity_save_button.dart';
import 'models/activity_form_models.dart';
import '../helper/categories.dart';
import '../model/checklist.dart';
import '../model/activity_media.dart';
import '../model/profile.dart';
import '../model/enum/mood.dart';
import '../model/activity.dart';
import '../service/profile_manager.dart';
import '../service/activity_manager.dart';

class AddActivityBottomSheet extends StatefulWidget {
  const AddActivityBottomSheet({super.key});

  @override
  State<AddActivityBottomSheet> createState() => _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState extends State<AddActivityBottomSheet> {
  bool _showDateTimeInput = false;
  DateTime? _selectedDate;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _tagsController;
  TimeOfDay? _selectedTime;
  bool _isImportant = false;
  bool _isCompleted = false;
  String _selectedCategory = getAllActivityCategories().first;
  int _durationHours = 0;
  int _durationMinutes = 0;
  List<String> _tags = [];
  List<ChecklistItem> _checklist = [];
  List<ActivityMedia> _attachments = [];
  Profile? _selectedProfile;
  ActivityMood _mood = ActivityMood.happy;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _tagsController = TextEditingController();
    _selectedTime = TimeOfDay.now();
    _selectedDate = DateTime.now();
    
    // Set the current profile as default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileManager = Provider.of<ProfileManager>(context, listen: false);
      setState(() {
        _selectedProfile = profileManager.currentProfile;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  ActivityFormData get _formData => ActivityFormData(
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        category: _selectedCategory,
        date: _selectedDate,
        time: _selectedTime,
        durationHours: _durationHours,
        durationMinutes: _durationMinutes,
        tags: _tags,
        isImportant: _isImportant,
        isCompleted: _isCompleted,
        checklist: _checklist,
        attachments: _attachments,
        selectedProfile: _selectedProfile,
        mood: _mood,
      );

  void _saveActivity() async {
    if (!_formData.isValid) {
      String message = 'Please complete the following:';
      List<String> missing = [];
      
      if (_titleController.text.trim().isEmpty) {
        missing.add('Activity title');
      }
      if (_selectedProfile == null) {
        missing.add('Select a profile');
      }
      
      if (missing.isNotEmpty) {
        message += '\n• ${missing.join('\n• ')}';
      }
      
      ActivityFormUtils.showValidationMessage(context, message);
      return;
    }

    try {
      // Get ActivityManager from context
      final activityManager = Provider.of<ActivityManager>(context, listen: false);
      
      // Create DateTime from selected date and time
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Create Duration from hours and minutes
      final duration = Duration(
        hours: _durationHours,
        minutes: _durationMinutes,
      );

      // Create the activity
      final activity = Activity(
        activityId: const Uuid().v4(), // Generate unique ID
        activityTitle: _titleController.text.trim(),
        activityContent: _descriptionController.text.trim(),
        activityMedia: _attachments,
        activityCategory: _selectedCategory,
        activityMood: _mood,
        activityDatetime: selectedDateTime,
        activityModifiedDate: DateTime.now(),
        activityStarred: _isImportant,
        activityProfileId: _selectedProfile!.profileId,
        activityDone: _isCompleted,
        activityNotify: false, // Default to false, can be made configurable later
        checklist: _checklist,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        tags: _tags,
        activityDuration: duration.inMinutes > 0 ? duration : null,
        reminderTime: null, // Can be added later if needed
      );

      // Save the activity
      await activityManager.addActivity(activity);

      // Show success message and close
      ActivityFormUtils.showSuccessMessage(context, _formData);
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors during saving
      ActivityFormUtils.showValidationMessage(
        context, 
        'Error saving activity: $e'
      );
    }
  }

  void _onTagAdded(String tag) {
    setState(() {
      _tags.add(tag);
      _tagsController.clear();
    });
  }

  void _onTagRemoved(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _onChecklistChanged(List<ChecklistItem> checklist) {
    setState(() {
      _checklist = checklist;
    });
  }

  void _onAttachmentsChanged(List<ActivityMedia> attachments) {
    setState(() {
      _attachments = attachments;
    });
  }

  void _onProfileChanged(Profile? profile) {
    setState(() {
      _selectedProfile = profile;
    });
  }

  void _onMoodChanged() {
    setState(() {
      _mood = _mood.next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _showDateTimeInput ? 0.9 : 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: _showDateTimeInput ? [0.5, 0.9] : [0.5, 0.7],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 80.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDragHandle(context),
                        ActivityFormHeader(
                          isImportant: _isImportant,
                          isCompleted: _isCompleted,
                          selectedCategory: _selectedCategory,
                          selectedProfile: _selectedProfile,
                          mood: _mood,
                          onImportantToggle: () =>
                              setState(() => _isImportant = !_isImportant),
                          onCompletedToggle: () =>
                              setState(() => _isCompleted = !_isCompleted),
                          onMoodChanged: _onMoodChanged,
                          onCategoryChanged: (category) =>
                              setState(() => _selectedCategory = category),
                          onProfileChanged: _onProfileChanged,
                        ),
                        const SizedBox(height: 24),
                        ActivityTextField(
                          controller: _titleController,
                          labelText: 'Activity Title*',
                          hintText: 'What did you do?',
                          prefixIcon: Icons.title_outlined,
                          maxLength: 100,
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        ActivityTextField(
                          controller: _descriptionController,
                          labelText: 'Description (Optional)',
                          hintText: 'Add more details about the activity...',
                          prefixIcon: Icons.description_outlined,
                          maxLength: 500,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildExpandableDetailsButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              ActivitySaveButton(
                isValid: _formData.isValid,
                onSave: _saveActivity,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildExpandableDetailsButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: !_showDateTimeInput
          ? SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('addTimeBtn'),
                icon: Icon(
                  Icons.expand_more_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                label: const Text('Add more details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).iconTheme.color,
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  setState(() {
                    _showDateTimeInput = true;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {});
                  });
                },
              ),
            )
          : ActivityDetailsSection(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              locationController: _locationController,
              durationHours: _durationHours,
              durationMinutes: _durationMinutes,
              tagsController: _tagsController,
              tags: _tags,
              checklist: _checklist,
              attachments: _attachments,
              onDateChanged: (date) => setState(() => _selectedDate = date),
              onTimeChanged: (time) => setState(() => _selectedTime = time),
              onDurationChanged: (hours, minutes) => setState(() {
                _durationHours = hours;
                _durationMinutes = minutes;
              }),
              onTagAdded: _onTagAdded,
              onTagRemoved: _onTagRemoved,
              onChecklistChanged: _onChecklistChanged,
              onAttachmentsChanged: _onAttachmentsChanged,
            ),
    );
  }
}
