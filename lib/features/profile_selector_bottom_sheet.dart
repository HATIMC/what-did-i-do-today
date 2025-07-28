import 'package:flutter/material.dart';
import 'package:hello_world/features/add_profile_bottom_sheet.dart';
import 'package:hello_world/model/profile.dart'; // Add Profile import
import 'package:hello_world/service/profile_manager.dart';
import 'package:provider/provider.dart';

class ProfileSelectorBottomSheet extends StatelessWidget {
  const ProfileSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final profileManager = Provider.of<ProfileManager>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...profileManager.profiles.map((profile) {
            return ListTile(
              leading: Text(
                profile.profileImage,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(profile.profileName),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) =>
                          AddProfileBottomSheet(existingProfile: profile),
                    );
                  } else if (value == 'delete') {
                    // Prevent deletion if this is the only profile
                    if (profileManager.profiles.length > 1) {
                      _showDeleteConfirmationDialog(
                        context,
                        profile,
                        profileManager,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cannot delete the last profile. At least one profile must exist.',
                          ),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  // Only show delete option if there's more than one profile
                  if (profileManager.profiles.length > 1)
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
              onTap: () {
                profileManager.setCurrentProfile(profile.profileId);
                Navigator.pop(context);
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add New Profile'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => const AddProfileBottomSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Show Material Design confirmation dialog for profile deletion
  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    Profile profile,
    ProfileManager profileManager,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Force user to make a choice
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_outlined,
              color: colorScheme.onErrorContainer,
              size: 32,
            ),
          ),
          title: Text(
            'Delete Profile?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        profile.profileImage,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        profile.profileName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Warning message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.delete_forever_outlined,
                      color: colorScheme.error,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This action cannot be undone',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deleting this profile will permanently remove:\n• All activities and tasks associated with this profile\n• Personal settings and preferences\n• Any saved data linked to this profile',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Cancel'),
            ),

            // Delete button
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 18),
                  const SizedBox(width: 8),
                  const Text('Delete Profile'),
                ],
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actionsAlignment: MainAxisAlignment.spaceBetween,
        );
      },
    );

    // If user confirmed deletion, proceed with the deletion
    if (result == true) {
      final success = await profileManager.deleteProfile(profile.profileId);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.onError),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Failed to delete profile. Please try again.'),
                ),
              ],
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (success && context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: colorScheme.onPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Profile "${profile.profileName}" deleted successfully',
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
