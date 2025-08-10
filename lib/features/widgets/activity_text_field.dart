import 'package:flutter/material.dart';

class ActivityTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final int? maxLength;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final VoidCallback? onChanged;

  const ActivityTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged != null ? (_) => onChanged!() : null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
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
          prefixIcon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      maxLines: maxLines,
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) =>
              null,
    );
  }
}
