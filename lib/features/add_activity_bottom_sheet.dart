import 'package:flutter/material.dart';
import 'package:hello_world/helper/categories.dart';
import 'package:hello_world/model/enum/mood.dart';
import 'package:hello_world/model/activity_media.dart';

class AddActivityBottomSheet extends StatefulWidget {
  const AddActivityBottomSheet({super.key});

  @override
  State<AddActivityBottomSheet> createState() => _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState extends State<AddActivityBottomSheet> {
  String? selectedCategory;
  ActivityMood? selectedMood;
  bool isStarred = false;
  bool isDone = false;
  bool notificationEnabled = false;
  List<String> tags = [];
  final TextEditingController tagsController = TextEditingController();

  // Duration variables
  int selectedHours = 0;
  int selectedMinutes = 0;

  // Checklist variables
  List<Map<String, dynamic>> checklistItems = [];
  final TextEditingController checklistTitleController =
      TextEditingController();
  final TextEditingController checklistContentController =
      TextEditingController();

  // Media variables
  List<ActivityMedia> mediaItems = []; // This will store ActivityMedia objects

  String get formattedDuration {
    if (selectedHours == 0 && selectedMinutes == 0) {
      return '';
    }
    String hourText = selectedHours == 1 ? 'hour' : 'hours';
    String minuteText = selectedMinutes == 1 ? 'minute' : 'minutes';

    if (selectedHours > 0 && selectedMinutes > 0) {
      return '$selectedHours $hourText, $selectedMinutes $minuteText';
    } else if (selectedHours > 0) {
      return '$selectedHours $hourText';
    } else {
      return '$selectedMinutes $minuteText';
    }
  }

  Future<void> _showDurationPicker() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempHours = selectedHours;
        int tempMinutes = selectedMinutes;

        return AlertDialog(
          title: const Text('Select Duration'),
          content: Container(
            height: 200,
            child: Row(
              children: [
                // Hours picker
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Hours',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: const FixedExtentScrollPhysics(),
                          controller: FixedExtentScrollController(
                            initialItem: selectedHours,
                          ),
                          onSelectedItemChanged: (int index) {
                            tempHours = index;
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '$index',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                            childCount: 25, // 0-24 hours
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 100,
                  color: Theme.of(context).dividerColor,
                ),
                const SizedBox(width: 20),
                // Minutes picker
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Minutes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: const FixedExtentScrollPhysics(),
                          controller: FixedExtentScrollController(
                            initialItem: (selectedMinutes / 5).round(),
                          ),
                          onSelectedItemChanged: (int index) {
                            tempMinutes = index * 5; // 5-minute intervals
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              int minutes = index * 5;
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '$minutes',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                            childCount: 12, // 0, 5, 10, ... 55 minutes
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedHours = tempHours;
                  selectedMinutes = tempMinutes;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Set Duration'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddChecklistDialog() async {
    checklistTitleController.clear();
    checklistContentController.clear();
    List<ActivityMedia> tempMedia = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Checklist Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title field
                    TextField(
                      controller: checklistTitleController,
                      decoration: InputDecoration(
                        labelText: 'Title*',
                        hintText: 'Enter checklist item title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Content field
                    TextField(
                      controller: checklistContentController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add details (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Media section
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                tempMedia.add(
                                  ActivityMedia(
                                    mediaId: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    mediaPath:
                                        'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                  ),
                                );
                              });
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Photo'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                tempMedia.add(
                                  ActivityMedia(
                                    mediaId: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    mediaPath:
                                        'file_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                  ),
                                );
                              });
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text('File'),
                          ),
                        ),
                      ],
                    ),
                    // Show attached media
                    if (tempMedia.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...tempMedia.map((media) {
                        bool isPhoto =
                            media.mediaPath.contains('.jpg') ||
                            media.mediaPath.contains('.png');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPhoto ? Icons.image : Icons.description,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  media.mediaPath,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setDialogState(() {
                                    tempMedia.remove(media);
                                  });
                                },
                                icon: const Icon(Icons.close, size: 16),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (checklistTitleController.text.trim().isNotEmpty) {
                      setState(() {
                        checklistItems.add({
                          'id': DateTime.now().millisecondsSinceEpoch
                              .toString(),
                          'title': checklistTitleController.text.trim(),
                          'content': checklistContentController.text.trim(),
                          'media': tempMedia, // Now using List<ActivityMedia>
                        });
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Item'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle for the bottom sheet
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                'Add New Activity',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Activity Title
              TextField(
                decoration: InputDecoration(
                  labelText: 'Activity Title*',
                  hintText: 'Enter activity title',
                  prefixIcon: const Icon(Icons.title),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Activity Content/Description
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your activity...',
                  prefixIcon: const Icon(Icons.description),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category*',
                  prefixIcon: selectedCategory != null
                      ? Icon(getIconForCategory(selectedCategory!))
                      : const Icon(Icons.category),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                items: getAllActivityCategories().map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(getIconForCategory(category), size: 20),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Mood Selection
              Text('Mood', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ActivityMood.values.map((mood) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMood = mood;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedMood == mood
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.transparent,
                        ),
                        child: getMoodIconWidget(mood, size: 28),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Date*',
                        hintText: 'Select date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      readOnly: true,
                      onTap: () async {
                        await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Time*',
                        hintText: 'Select time',
                        prefixIcon: const Icon(Icons.access_time),
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      readOnly: true,
                      onTap: () async {
                        await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location
              TextField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where did this happen?',
                  prefixIcon: const Icon(Icons.location_on),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Duration
              TextField(
                decoration: InputDecoration(
                  labelText: 'Duration',
                  hintText: 'How long did it take?',
                  prefixIcon: const Icon(Icons.timer),
                  suffixIcon: const Icon(Icons.keyboard_arrow_down),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                readOnly: true,
                controller: TextEditingController(text: formattedDuration),
                onTap: _showDurationPicker,
              ),
              const SizedBox(height: 16),

              // Tags
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Add tags separated by commas',
                  prefixIcon: const Icon(Icons.tag),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onDeleted: () {
                        setState(() {
                          tags.remove(tag);
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // Reminder Time
              TextField(
                decoration: InputDecoration(
                  labelText: 'Reminder Time',
                  hintText: 'Set reminder for this activity',
                  prefixIcon: const Icon(Icons.alarm),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                readOnly: true,
                onTap: () async {
                  await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Checklist Section
              Text('Checklist', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Add checklist item button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _showAddChecklistDialog(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_task,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Checklist Item',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Display checklist items
                      if (checklistItems.isNotEmpty)
                        Column(
                          children: checklistItems.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> item = entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with checkbox and delete button
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_box_outline_blank,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item['title'] ?? 'Untitled',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              checklistItems.removeAt(index);
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                    // Content (if available)
                                    if (item['content'] != null &&
                                        item['content'].isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 28,
                                          top: 4,
                                        ),
                                        child: Text(
                                          item['content'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    // Media attachments (if available)
                                    if (item['media'] != null &&
                                        (item['media'] as List).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 28,
                                          top: 8,
                                        ),
                                        child: Wrap(
                                          spacing: 6,
                                          children: (item['media'] as List<ActivityMedia>).map(
                                            (media) {
                                              bool isPhoto =
                                                  media.mediaPath.contains(
                                                    '.jpg',
                                                  ) ||
                                                  media.mediaPath.contains(
                                                    '.png',
                                                  );
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isPhoto
                                                          ? Icons.image
                                                          : Icons.description,
                                                      size: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      media.mediaPath
                                                          .split('_')
                                                          .first,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Media Section
              Text(
                'Attachments',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Media upload buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Simulate adding a photo
                                  setState(() {
                                    mediaItems.add(
                                      ActivityMedia(
                                        mediaId: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        mediaPath:
                                            'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                      ),
                                    );
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Photo added (demo)'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Simulate adding a file
                                  setState(() {
                                    mediaItems.add(
                                      ActivityMedia(
                                        mediaId: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        mediaPath:
                                            'document_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                      ),
                                    );
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('File added (demo)'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.attach_file,
                                        size: 32,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add File',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Display attached media
                      if (mediaItems.isNotEmpty)
                        Column(
                          children: mediaItems.asMap().entries.map((entry) {
                            int index = entry.key;
                            ActivityMedia media = entry.value;
                            String fileName = media.mediaPath;
                            bool isPhoto =
                                fileName.contains('.jpg') ||
                                fileName.contains('.png');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: Icon(
                                  isPhoto ? Icons.image : Icons.description,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                title: Text(
                                  fileName,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'ID: ${media.mediaId}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      mediaItems.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.close, size: 20),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Toggle Options
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Mark as Important'),
                        subtitle: const Text('Star this activity'),
                        value: isStarred,
                        onChanged: (bool value) {
                          setState(() {
                            isStarred = value;
                          });
                        },
                        secondary: Icon(
                          isStarred ? Icons.star : Icons.star_border,
                          color: isStarred ? Colors.amber : null,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Mark as Completed'),
                        subtitle: const Text('This activity is done'),
                        value: isDone,
                        onChanged: (bool value) {
                          setState(() {
                            isDone = value;
                          });
                        },
                        secondary: Icon(
                          isDone
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isDone ? Colors.green : null,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Enable Notifications'),
                        subtitle: const Text(
                          'Get notified about this activity',
                        ),
                        value: notificationEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            notificationEnabled = value;
                          });
                        },
                        secondary: Icon(
                          notificationEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle saving the activity
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Activity saved (dummy)'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Save Activity',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tagsController.dispose();
    checklistTitleController.dispose();
    checklistContentController.dispose();
    super.dispose();
  }
}
