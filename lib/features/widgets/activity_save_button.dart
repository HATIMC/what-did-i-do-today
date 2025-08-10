import 'package:flutter/material.dart';

class ActivitySaveButton extends StatelessWidget {
  final bool isValid;
  final VoidCallback onSave;

  const ActivitySaveButton({
    super.key,
    required this.isValid,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: isValid ? onSave : null,
          backgroundColor: isValid
              ? Colors.transparent
              : Theme.of(context).colorScheme.surfaceVariant,
          elevation: 0,
          shape: const CircleBorder(),
          child: Icon(
            Icons.check,
            size: 36,
            color: isValid
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            shadows: isValid
                ? [
                    Shadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          tooltip: 'Save Activity',
        ),
      ),
    );
  }
}
