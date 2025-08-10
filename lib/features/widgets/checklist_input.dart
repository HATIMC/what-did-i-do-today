import 'package:flutter/material.dart';
import '../../model/checklist.dart';
import 'add_checklist_bottom_sheet.dart';

class ChecklistInput extends StatelessWidget {
  final List<ChecklistItem> checklist;
  final Function(List<ChecklistItem>) onChecklistChanged;

  const ChecklistInput({
    super.key,
    required this.checklist,
    required this.onChecklistChanged,
  });

  void _showAddChecklistBottomSheet(
    BuildContext context, {
    ChecklistItem? existingItem,
    int? editIndex,
  }) async {
    final result = await showModalBottomSheet<ChecklistItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => AddChecklistBottomSheet(existingItem: existingItem),
    );

    if (result != null) {
      final updatedChecklist = List<ChecklistItem>.from(checklist);
      if (editIndex != null) {
        updatedChecklist[editIndex] = result;
      } else {
        updatedChecklist.add(result);
      }
      onChecklistChanged(updatedChecklist);
    }
  }

  void _toggleChecklistItem(int index) {
    final updatedChecklist = List<ChecklistItem>.from(checklist);
    updatedChecklist[index] = checklist[index].copyWith(
      isChecked: !checklist[index].isChecked,
    );
    onChecklistChanged(updatedChecklist);
  }

  void _removeChecklistItem(int index) {
    final updatedChecklist = List<ChecklistItem>.from(checklist);
    updatedChecklist.removeAt(index);
    onChecklistChanged(updatedChecklist);
  }

  String _truncateDescription(String description, int maxLength) {
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add checklist button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showAddChecklistBottomSheet(context),
            icon: Icon(
              Icons.add_task_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            label: const Text('Add Checklist Item'),
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

        // Checklist items display
        if (checklist.isNotEmpty) ...[
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
                      Icons.checklist_rtl_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Checklist Items (${checklist.length})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...checklist.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
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
                          // Header row with checkbox, title, and actions
                          Row(
                            children: [
                              // Checkbox
                              InkWell(
                                onTap: () => _toggleChecklistItem(index),
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    item.isChecked
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: item.isChecked
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Title - Clickable to edit
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showAddChecklistBottomSheet(
                                    context,
                                    existingItem: item,
                                    editIndex: index,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      item.checklistTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            decoration: item.isChecked
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: item.isChecked
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onSurfaceVariant
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ),
                              ),

                              // Media count badge
                              if (item.checklistMedia.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.attachment,
                                        size: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${item.checklistMedia.length}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],

                              // Delete button
                              IconButton(
                                onPressed: () => _removeChecklistItem(index),
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 16,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                padding: const EdgeInsets.all(4),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Description (if available) - Clickable to edit
                          if (item.checklistContent.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: InkWell(
                                onTap: () => _showAddChecklistBottomSheet(
                                  context,
                                  existingItem: item,
                                  editIndex: index,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    _truncateDescription(
                                      item.checklistContent,
                                      100,
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          decoration: item.isChecked
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
