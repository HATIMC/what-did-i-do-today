import 'package:flutter/material.dart';
import '../../model/checklist.dart';
import '../../model/activity_media.dart';

class AddChecklistBottomSheet extends StatefulWidget {
  final ChecklistItem? existingItem;

  const AddChecklistBottomSheet({super.key, this.existingItem});

  @override
  State<AddChecklistBottomSheet> createState() =>
      _AddChecklistBottomSheetState();
}

class _AddChecklistBottomSheetState extends State<AddChecklistBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<ActivityMedia> _mediaItems = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingItem?.checklistTitle ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingItem?.checklistContent ?? '',
    );
    _mediaItems = List.from(widget.existingItem?.checklistMedia ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addMedia() {
    // TODO: Implement file picker for media
    final newMedia = ActivityMedia(
      mediaId: DateTime.now().millisecondsSinceEpoch.toString(),
      mediaPath: 'placeholder_media_${DateTime.now().millisecondsSinceEpoch}',
    );

    setState(() {
      _mediaItems.add(newMedia);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Media picker integration needed'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaItems.removeAt(index);
    });
  }

  void _saveChecklist() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a checklist title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final checklistItem = ChecklistItem(
      checklistId:
          widget.existingItem?.checklistId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      checklistTitle: _titleController.text.trim(),
      checklistContent: _descriptionController.text.trim(),
      checklistMedia: _mediaItems,
      isChecked: widget.existingItem?.isChecked ?? false,
    );

    Navigator.pop(context, checklistItem);
  }

  IconData _getMediaIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_outlined;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file_outlined;
      case 'mp3':
      case 'wav':
        return Icons.audio_file_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
            // Drag handle
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

            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existingItem != null
                        ? 'Edit Checklist Item'
                        : 'Add Checklist Item',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Checklist Title*',
                hintText: 'Enter checklist item title',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.checklist_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Description Input
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add more details about this checklist item...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.description_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Add Media Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addMedia,
                icon: Icon(
                  Icons.attach_file_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                label: Text('Add Media (${_mediaItems.length})'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            // Media Items Display
            if (_mediaItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Media Items (${_mediaItems.length})',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _mediaItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final media = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getMediaIcon(media.mediaPath),
                                size: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Media ${index + 1}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => _removeMedia(index),
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveChecklist,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Save Checklist Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
