import 'package:flutter/material.dart';
import 'package:hello_world/features/add_profile_bottom_sheet.dart';
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
                    profileManager.deleteProfile(profile.profileId);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
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
}
