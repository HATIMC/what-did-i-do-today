import 'package:flutter/material.dart';
import 'package:hello_world/features/profile_selector_bottom_sheet.dart';
import 'package:hello_world/service/profile_manager.dart';
import 'package:hello_world/service/theme_manager.dart'; // Import the theme manager
import 'package:provider/provider.dart'; // Import provider package

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
    _nameController = TextEditingController();
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
    final profileManager = Provider.of<ProfileManager>(context);
    final currentProfile = profileManager.currentProfile;

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
            // Drag handle
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
            // Profile Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Profile",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (_) => const ProfileSelectorBottomSheet(),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            currentProfile?.profileImage ?? "🙂",
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentProfile?.profileName ?? "Select Profile",
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // App Lock Toggle
            SwitchListTile(
              title: const Text('App Lock'),
              subtitle: const Text(
                'Require authentication when opening the app',
              ),
              value: themeManager.isLockEnabled,
              onChanged: (bool value) {
                themeManager.setLockEnabled(value);
              },
            ),

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
