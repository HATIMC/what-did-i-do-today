import 'package:flutter/material.dart';

class TagsInput extends StatelessWidget {
  final TextEditingController controller;
  final List<String> tags;
  final Function(String) onTagAdded;
  final Function(String) onTagRemoved;

  const TagsInput({
    super.key,
    required this.controller,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Tags',
            hintText: 'Type and press Space or Enter to add tags',
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
            labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            prefixIcon: Icon(
              Icons.label_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          onChanged: (value) {
            // Handle space key to add tags
            if (value.endsWith(' ')) {
              final tag = value.trim();
              if (tag.isNotEmpty && !tags.contains(tag)) {
                onTagAdded(tag);
              }
            }
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty && !tags.contains(value.trim())) {
              onTagAdded(value.trim());
            }
          },
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => onTagRemoved(tag),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
