import 'package:flutter/material.dart';

class AboutBottomSheet extends StatelessWidget {
  const AboutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Make the content scrollable
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
              'About',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text('This app demonstrates Material 3 design in Flutter.'),
            const Text('Version 1.0.0'),
            const Text('Developed with Flutter and Material Design 3 guidelines.'),
            const Text('This is a sample application to showcase basic UI elements.'),
            const Text('Feel free to explore and modify the code.'),
            const Text('Thank you for using this application!'),
            // Adding more text to demonstrate scrollability
            const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
            const Text('Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
            const Text('Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'),
            const Text('Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'),
            const Text('Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
