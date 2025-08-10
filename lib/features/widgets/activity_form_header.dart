import 'package:flutter/material.dart';
import '../category_selector_bottom_sheet.dart';
import '../../helper/categories.dart';
import '../../model/profile.dart';
import '../../model/enum/mood.dart';

class ActivityFormHeader extends StatelessWidget {
  final bool isImportant;
  final bool isCompleted;
  final String selectedCategory;
  final Profile? selectedProfile;
  final ActivityMood mood;
  final VoidCallback onImportantToggle;
  final VoidCallback onCompletedToggle;
  final VoidCallback onMoodChanged;
  final Function(String) onCategoryChanged;
  final Function(Profile?) onProfileChanged;

  const ActivityFormHeader({
    super.key,
    required this.isImportant,
    required this.isCompleted,
    required this.selectedCategory,
    required this.selectedProfile,
    required this.mood,
    required this.onImportantToggle,
    required this.onCompletedToggle,
    required this.onMoodChanged,
    required this.onCategoryChanged,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Add New Activity',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Profile display (left aligned) - Non-clickable
            Expanded(
              child: selectedProfile != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                              text: 'For ',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextSpan(
                              text: selectedProfile!.profileName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      child: Text(
                        'No profile selected',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Action buttons (right aligned)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mood button
                IconButton(
                  onPressed: onMoodChanged,
                  icon: Text(mood.emoji, style: const TextStyle(fontSize: 20)),
                  tooltip: 'Mood: ${mood.name}',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Important toggle button
                IconButton(
                  onPressed: onImportantToggle,
                  icon: Icon(
                    isImportant ? Icons.star : Icons.star_outline,
                    color: isImportant
                        ? Colors.amber
                        : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: 'Mark as Important',
                  style: IconButton.styleFrom(
                    backgroundColor: isImportant
                        ? Colors.amber.withOpacity(0.1)
                        : Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Completed toggle button
                IconButton(
                  onPressed: onCompletedToggle,
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: isCompleted
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: 'Mark as Completed',
                  style: IconButton.styleFrom(
                    backgroundColor: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Category icon button
                IconButton(
                  onPressed: () async {
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (context) => CategorySelectorBottomSheet(
                        selectedCategory: selectedCategory,
                        onCategorySelected: (cat) {
                          Navigator.pop(context, cat);
                        },
                      ),
                    );
                    if (selected != null && selected != selectedCategory) {
                      onCategoryChanged(selected);
                    }
                  },
                  icon: Icon(
                    getIconForCategory(selectedCategory),
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: 'Select Category',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
