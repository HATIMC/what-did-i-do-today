import 'package:flutter/material.dart';
import '../../model/activity_media.dart';

class AttachmentsInput extends StatelessWidget {
  final List<ActivityMedia> attachments;
  final Function(List<ActivityMedia>) onAttachmentsChanged;

  const AttachmentsInput({
    super.key,
    required this.attachments,
    required this.onAttachmentsChanged,
  });

  void _addAttachment(BuildContext context) async {
    // TODO: Implement file picker functionality
    // For now, we'll add a placeholder
    final newAttachment = ActivityMedia(
      mediaId: DateTime.now().millisecondsSinceEpoch.toString(),
      mediaPath: 'placeholder_path_${DateTime.now().millisecondsSinceEpoch}',
    );

    final updatedAttachments = [...attachments, newAttachment];
    onAttachmentsChanged(updatedAttachments);

    // Show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('File picker integration needed'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _removeAttachment(int index) {
    final updatedAttachments = List<ActivityMedia>.from(attachments);
    updatedAttachments.removeAt(index);
    onAttachmentsChanged(updatedAttachments);
  }

  IconData _getFileIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
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

  String _getFileName(String path) {
    return path.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add attachment button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addAttachment(context),
            icon: Icon(
              Icons.attach_file_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            label: const Text('Add Attachments'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              textStyle: Theme.of(context).textTheme.bodyLarge,
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // Attachments display
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attachment_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Attachments (${attachments.length})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...attachments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final attachment = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getFileIcon(attachment.mediaPath),
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getFileName(attachment.mediaPath),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'File ID: ${attachment.mediaId}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeAttachment(index),
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.error,
                              size: 16,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: const EdgeInsets.all(4),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
