import 'package:flutter/material.dart';

class AddActivityBottomSheet extends StatelessWidget {
  const AddActivityBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Text(
              'Add New Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Activity Title',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    readOnly: true, // Make it read-only for date picker
                    onTap: () async {
                      // Dummy date picker
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      // In a real app, you'd update the text field with the selected date
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Time',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    readOnly: true, // Make it read-only for time picker
                    onTap: () async {
                      // Dummy time picker
                      await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      // In a real app, you'd update the text field with the selected time
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Handle saving the activity
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Activity saved (dummy)')),
                  );
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: const Text('Save Activity'),
              ),
            ),
            const SizedBox(height: 16), // Extra space for scrollability
          ],
        ),
      ),
    );
  }
}
