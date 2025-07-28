import 'package:flutter/material.dart';
import 'package:hello_world/model/profile.dart';
import 'package:hello_world/service/profile_manager.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddProfileBottomSheet extends StatefulWidget {
  final Profile? existingProfile;
  final bool
  isMandatory; // New parameter to indicate if profile creation is mandatory

  const AddProfileBottomSheet({
    super.key,
    this.existingProfile,
    this.isMandatory = false, // Default to false for backward compatibility
  });

  @override
  State<AddProfileBottomSheet> createState() => _AddProfileBottomSheetState();
}

class _AddProfileBottomSheetState extends State<AddProfileBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedEmoji = '🙂';

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _nameController.text = widget.existingProfile!.profileName;
      _selectedEmoji = widget.existingProfile!.profileImage;
    }
  }

  final List<String> _emojiOptions = [
    "😀",
    "😃",
    "😄",
    "😁",
    "😆",
    "😅",
    "😂",
    "🤣",
    "😊",
    "😇",
    "🙂",
    "🙃",
    "😉",
    "😌",
    "😍",
    "🥰",
    "😘",
    "😗",
    "😙",
    "😚",
    "😋",
    "😛",
    "😜",
    "🤪",
    "😝",
    "🤑",
    "🤗",
    "🤭",
    "🤫",
    "🤔",
    "🤐",
    "🤨",
    "😐",
    "😑",
    "😶",
    "😏",
    "😒",
    "🙄",
    "😬",
    "🤥",
    "😌",
    "😔",
    "😪",
    "🤤",
    "😴",
    "😷",
    "🤒",
    "🤕",
    "🤢",
    "🤮",
    "🥴",
    "😵",
    "🤯",
    "🤠",
    "🥳",
    "😎",
    "🤓",
    "🧐",
    "😕",
    "😟",
    "🙁",
    "☹️",
    "😮",
    "😯",
    "😲",
    "😳",
    "🥺",
    "😦",
    "😧",
    "😨",
    "😰",
    "😥",
    "😢",
    "😭",
    "😱",
    "😖",
    "😣",
    "😞",
    "😓",
    "😩",
    "😫",
    "🥱",
    "😤",
    "😡",
    "😠",
    "🤬",
    "😈",
    "👿",
    "💀",
    "☠️",
    "👻",
    "👽",
    "🤖",
    "😺",
    "😸",
    "😹",
    "😻",
    "🧑",
    "👩",
    "👨",
    "🧒",
    "👦",
    "👧",
    "👶",
    "👵",
    "👴",
    "🧓",
    "🧑‍🎓",
    "👨‍🎓",
    "👩‍🎓",
    "🧑‍🏫",
    "👨‍🏫",
    "👩‍🏫",
    "🧑‍⚕️",
    "👨‍⚕️",
    "👩‍⚕️",
    "🧑‍💻",
    "👨‍💻",
    "👩‍💻",
    "🧑‍🎨",
    "👨‍🎨",
    "👩‍🎨",
    "🧑‍🚀",
    "👨‍🚀",
    "👩‍🚀",
    "🧑‍🍳",
    "👨‍🍳",
    "👩‍🍳",
    "🧑‍🔧",
    "👨‍🔧",
    "👩‍🔧",
    "🧑‍🏭",
    "👨‍🏭",
    "👩‍🏭",
    "🧑‍🚒",
    "👨‍🚒",
    "👩‍🚒",
    "🧑‍✈️",
    "👨‍✈️",
    "👩‍✈️",
    "🧑‍⚖️",
    "👨‍⚖️",
    "👩‍⚖️",
    "🧙",
    "🧝",
    "🧛",
    "🧟",
    "🧞",
    "🧜",
    "🧚",
    "🧞‍♂️",
    "🧞‍♀️",
    "🐶",
    "🐱",
    "🐭",
    "🐹",
    "🐰",
    "🦊",
    "🐻",
    "🐼",
    "🐨",
    "🐯",
    "🦁",
    "🐮",
    "🐷",
    "🐽",
    "🐸",
    "🐵",
    "🙈",
    "🙉",
    "🙊",
    "🦄",
    "🐔",
    "🐧",
    "🐦",
    "🐤",
    "🐣",
    "🐥",
    "🐺",
    "🐗",
    "🐴",
    "🐝",
    "🐛",
    "🐌",
    "🐞",
    "🐜",
    "🦋",
    "🐢",
    "🐍",
    "🦎",
    "🐙",
    "🐠",
    "⭐",
    "🌟",
    "💫",
    "⚡",
    "🔥",
    "💥",
    "🌈",
    "🌞",
    "🌝",
    "🌚",
    "🌙",
    "☀️",
    "❄️",
    "🌊",
    "🍀",
    "🌸",
    "🌼",
    "🌻",
    "🎈",
    "🎉",
    "🎊",
    "🎁",
    "🧸",
    "❤️",
    "🧡",
    "💛",
    "💚",
    "💙",
    "💜",
    "🖤",
    "🤍",
    "🤎",
    "💖",
    "💗",
    "💓",
    "💞",
    "💘",
    "💝",
    "💟",
    "🫶",
    "🎵",
    "🎶",
    "🎧",
    "🎤",
    "🎬",
    "🎨",
    "🎮",
    "🕹️",
    "🎯",
    "🧩",
    "🧱",
    "🛹",
    "🚲",
    "🛴",
    "🏀",
    "⚽",
    "🏈",
    "🥏",
    "🏓",
    "🏸",
  ];

  void _saveProfile(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a profile name")),
      );
      return;
    }

    final profileManager = Provider.of<ProfileManager>(context, listen: false);

    if (widget.existingProfile != null) {
      final profileId = widget.existingProfile!.profileId;
      profileManager.updateProfileName(profileId, name);
      profileManager.updateProfileImage(profileId, _selectedEmoji);
      profileManager.setCurrentProfile(profileId); // Ensure it's selected
    } else {
      final newProfile = Profile(
        profileId: const Uuid().v4(),
        profileName: name,
        profileImage: _selectedEmoji,
      );
      profileManager.addProfile(newProfile);
      profileManager.setCurrentProfile(newProfile.profileId);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = Padding(
      padding: MediaQuery.of(
        context,
      ).viewInsets, // 👈 this fixes keyboard overlap
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // 👈 allows sheet to resize properly
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Title
              Center(
                child: Text(
                  widget.existingProfile != null
                      ? 'Edit Profile'
                      : 'Create New Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Show mandatory message if this is required
              if (widget.isMandatory) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Profile creation is required to continue',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              /// Avatar Chooser
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Text(
                    _selectedEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              /// Emoji List
              ExpansionTile(
                title: const Text("Choose Emoji Avatar"),
                initiallyExpanded: false,
                tilePadding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 300, // Limit height to avoid over-expanding
                    child: GridView.builder(
                      itemCount: _emojiOptions.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        final emoji = _emojiOptions[index];
                        final isSelected = emoji == _selectedEmoji;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEmoji = emoji;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceVariant,
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              /// Profile Name Input
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              /// Save Button
              FilledButton.icon(
                onPressed: () => _saveProfile(context),
                icon: const Icon(Icons.save),
                label: const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );

    // If mandatory, wrap with PopScope to prevent dismissal
    if (widget.isMandatory) {
      return PopScope(
        canPop: false, // Prevent back button dismissal when mandatory
        child: content,
      );
    }

    return content;
  }
}
