import 'package:flutter/material.dart';
import 'package:hello_world/service/theme_manager.dart'; // Import the theme manager
import 'package:provider/provider.dart'; // Import provider package
import 'package:flutter/services.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({super.key});

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late TextEditingController _nameController;

  // A list of predefined Material 3 like seed colors
  final List<Color> _material3SeedColors = const [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controller with current user name from ThemeManager
    _nameController = TextEditingController(
      text: Provider.of<ThemeManager>(context, listen: false).userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the ThemeManager
    final themeManager = Provider.of<ThemeManager>(context);

    // Determine the current effective brightness of the app
    final bool isCurrentlyDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            // User Name Text Field - MOVED HERE
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'Guest', // Hint text for default
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  15,
                ), // Limit input to 15 characters
              ],
              onChanged: (value) {
                // Update user name in ThemeManager
                themeManager.setUserName(value.isEmpty ? 'Guest' : value);
              },
            ),
            const SizedBox(height: 16),
            // Dark Mode Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              // Set the value based on the actual current brightness of the theme
              value: isCurrentlyDarkMode,
              onChanged: (bool value) {
                // Toggle the theme mode in the ThemeManager
                themeManager.toggleTheme(value);
              },
            ),
            const Divider(), // Add a divider for separation
            const Text(
              'Theme Color',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Color Selector
            Wrap(
              spacing: 8.0, // horizontal spacing
              runSpacing: 8.0, // vertical spacing
              children: _material3SeedColors.map((color) {
                final bool isSelected =
                    themeManager.seedColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    themeManager.setSeedColor(color); // Set the new seed color
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: isSelected ? 3.0 : 0.0,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 24,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const Divider(),
            const Text('This is where your settings options will go.'),
            const Text('Option 1: Enable notifications'),
            const Text('Option 2: Change theme'),
            const Text('Option 3: Manage data'),
            const Text('Option 4: Privacy settings'),
            const Text('Option 5: Account management'),
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            ),
            const Text(
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
            const Text(
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
            ),
            const Text(
              'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
            ),
            const Text(
              'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
