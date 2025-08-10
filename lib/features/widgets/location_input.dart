import 'package:flutter/material.dart';

class LocationInput extends StatelessWidget {
  final TextEditingController controller;

  const LocationInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Location',
        hintText: 'Where did this happen?',
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
          Icons.location_on_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      textCapitalization: TextCapitalization.words,
      maxLength: 150,
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) =>
              null,
    );
  }
}
