import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hello_world/features/settings_bottom_sheet.dart'; // Updated import path
import 'package:hello_world/features/about_bottom_sheet.dart'; // Updated import path
import 'package:hello_world/features/add_activity_bottom_sheet.dart'; // New import for add activity bottom sheet
import 'package:hello_world/features/add_profile_bottom_sheet.dart'; // Import add profile bottom sheet
import 'package:hello_world/features/profile_selector_bottom_sheet.dart'; // Import profile selector bottom sheet
import 'package:hello_world/service/profile_manager.dart';
import 'package:hello_world/service/theme_manager.dart'; // Import theme manager
import 'package:hello_world/service/activity_manager.dart'; // Import activity manager
import 'package:hello_world/model/enum/mood.dart'; // Import activity mood
import 'package:provider/provider.dart'; // Import provider
import 'package:table_calendar/table_calendar.dart'; // Import table_calendar
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarVisible =
      false; // Changed to false to hide calendar initially
  late AnimationController _animationController;
  String _animatedText = '';
  bool _isAnimating = false;
  static const Duration _typingDelay = Duration(milliseconds: 50);
  static const Duration _mistakeDelay = Duration(milliseconds: 250);
  static const Duration _correctionDelay = Duration(milliseconds: 150);
  bool _showCursor = true;
  Timer? _cursorTimer;

  // We'll use this to track if the initial animation has run.
  // It won't be used for re-animation, but for the first load.
  bool _hasInitialGreetingAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeManager = Provider.of<ThemeManager>(context, listen: false);
      final profileManager = Provider.of<ProfileManager>(
        context,
        listen: false,
      );

      // Check if preferences are loaded AND profile manager has finished loading
      if (themeManager.preferencesLoaded &&
          profileManager.isLoaded &&
          !_hasInitialGreetingAnimated) {
        // Check if no profiles exist - force profile creation
        if (_shouldShowProfileSelector(profileManager)) {
          _showProfileSelectorBottomSheet();
        } else if (profileManager.currentProfile != null) {
          // Has profiles and current profile is set
          _startGreetingAnimation();
          _hasInitialGreetingAnimated = true;
        }
      } else if (!themeManager.preferencesLoaded || !profileManager.isLoaded) {
        // Listen to both managers for changes
        themeManager.addListener(_startInitialGreetingOnPreferencesLoad);
        profileManager.addListener(_startInitialGreetingOnPreferencesLoad);
      }

      // Add listener for profile changes to re-animate greeting
      profileManager.addListener(_onProfileChanged);
    });
  }

  void _startInitialGreetingOnPreferencesLoad() {
    if (!mounted) return;

    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final profileManager = Provider.of<ProfileManager>(context, listen: false);

    if (themeManager.preferencesLoaded &&
        profileManager.isLoaded &&
        !_hasInitialGreetingAnimated) {
      // Check if no profiles exist - force profile creation
      if (_shouldShowProfileSelector(profileManager)) {
        _showProfileSelectorBottomSheet();
      } else if (profileManager.currentProfile != null) {
        // Has profiles and current profile is set
        _startGreetingAnimation();
        _hasInitialGreetingAnimated = true;
      }

      // Remove both listeners
      themeManager.removeListener(_startInitialGreetingOnPreferencesLoad);
      profileManager.removeListener(_startInitialGreetingOnPreferencesLoad);
    }
  }

  void _onProfileChanged() {
    if (!mounted) return;

    // Only re-animate if the initial greeting has already been shown
    if (_hasInitialGreetingAnimated) {
      _startGreetingAnimation();
    }
  }

  // Check if we should show profile selector (no profiles exist)
  bool _shouldShowProfileSelector(ProfileManager profileManager) {
    return profileManager.profiles.isEmpty;
  }

  // Show profile selector bottom sheet
  Future<void> _showProfileSelectorBottomSheet({
    bool dismissible = false,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: dismissible, // Allow dismissal when called from emoji tap
      enableDrag: dismissible, // Allow dragging when called from emoji tap
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return PopScope(
          canPop: dismissible, // Allow back button when dismissible
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header with message
                Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome!',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please create your profile to get started',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

                // Add profile button
                Consumer<ProfileManager>(
                  builder: (context, profileManager, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showMandatoryProfileBottomSheet();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create Profile'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    // After profile selection, start greeting animation
    if (mounted) {
      _startGreetingAnimation();
      _hasInitialGreetingAnimated = true;
    }
  }

  // Show mandatory profile creation bottom sheet (non-dismissible)
  Future<void> _showMandatoryProfileBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Force user to create a profile
      enableDrag: false, // Prevent dismissing by dragging
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return const AddProfileBottomSheet(isMandatory: true);
      },
    );

    // After profile creation, start greeting animation
    if (mounted) {
      _startGreetingAnimation();
      _hasInitialGreetingAnimated = true;
    }
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    // Remove listeners from both managers
    if (mounted) {
      final themeManager = Provider.of<ThemeManager>(context, listen: false);
      final profileManager = Provider.of<ProfileManager>(
        context,
        listen: false,
      );

      themeManager.removeListener(_startInitialGreetingOnPreferencesLoad);
      profileManager.removeListener(_startInitialGreetingOnPreferencesLoad);
      profileManager.removeListener(_onProfileChanged);
    }

    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is returning to the foreground (e.g., from minimized, or after a call)
      _startGreetingAnimation();
    }
  }

  void _startGreetingAnimation() {
    // Only run if not currently animating
    if (_isAnimating || !mounted) return;

    // Add listen: false to prevent rebuild notifications
    final profile = Provider.of<ProfileManager>(
      context,
      listen: false,
    ).currentProfile;
    final String userName =
        profile?.profileName ?? 'Unknown'; // Changed 'unknown' to 'Guest'
    final String fullText = '${_getGreeting()} I am $userName';

    // Cancel any ongoing animation and reset
    _cursorTimer?.cancel();
    setState(() {
      _isAnimating = false; // Ensure it's false before starting new
      _animatedText = '';
      _showCursor = false; // Start with cursor hidden
    });

    setState(() {
      _isAnimating = true;
      _showCursor = true;
    });

    int currentIndex = 0;
    final random = Random();

    // Start the cursor blinking immediately
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted || !_isAnimating) {
        timer.cancel();
        setState(() => _showCursor = false); // Hide cursor when animation stops
        return;
      }
      setState(() => _showCursor = !_showCursor);
    });

    void typeNext() async {
      if (!mounted) {
        _isAnimating = false; // Mark as not animating if widget is disposed
        _cursorTimer?.cancel();
        return;
      }

      if (currentIndex >= fullText.length) {
        setState(() {
          _isAnimating = false;
          _showCursor = false;
        });
        _cursorTimer
            ?.cancel(); // Ensure cursor timer is cancelled when typing is complete
        return;
      }

      bool makeMistake =
          currentIndex > 2 && random.nextBool() && random.nextInt(5) == 0;

      if (makeMistake) {
        String wrongChar = _getRandomChar(exclude: fullText[currentIndex]);
        setState(() {
          _animatedText += wrongChar;
        });

        await Future.delayed(_mistakeDelay);
        if (!mounted) return;

        setState(() {
          _animatedText = _animatedText.substring(0, _animatedText.length - 1);
        });

        await Future.delayed(_correctionDelay);
        if (!mounted) return;
      }

      setState(() {
        _animatedText += fullText[currentIndex];
      });
      currentIndex++;

      await Future.delayed(_typingDelay);
      if (!mounted) return;
      typeNext();
    }

    typeNext();
  }

  String _getRandomChar({String exclude = ''}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,!? ';
    final random = Random();
    String char;
    do {
      char = chars[random.nextInt(chars.length)];
    } while (char == exclude);
    return char;
  }

  // Function to show a generic bottom sheet
  Future<void> _showBottomSheet(BuildContext context, Widget content) async {
    // Use await to wait for the bottom sheet to be dismissed
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return content;
      },
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );

    // This code will execute when the bottom sheet is dismissed
    if (mounted) {
      // Ensure the widget is still mounted before animating
      _startGreetingAnimation();
    }
  }

  // Helper function to determine the greeting based on time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour <= 8) {
      // 4:00 AM to 8:00 AM
      return 'Good Morning!';
    } else if (hour > 8 && hour < 12) {
      // 8:01 AM to 11:59 AM
      return 'Good Day!';
    } else if (hour >= 12 && hour <= 16) {
      // 12:00 PM to 4:00 PM
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!'; // Suggested greeting for this range
    }
  }

  String getActivityTitle(DateTime selectedDate) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final int diffDays = selected.difference(today).inDays;

    final List<String> weekdayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final String selectedWeekdayName = weekdayNames[selected.weekday - 1];

    if (diffDays == 0) {
      return 'What did I do today?';
    } else if (diffDays == -1) {
      return 'What did I do yesterday?';
    } else if (diffDays == 1) {
      return 'What will I do tomorrow?';
    }

    if (selected.isBefore(today)) {
      if (diffDays >= -7 && diffDays <= 2) {
        return 'What did I do last $selectedWeekdayName?';
      } else {
        if (selected.year == today.year - 1) {
          return 'What did I do last year?';
        }
        return 'What did I do that day?';
      }
    } else {
      if (diffDays >= 2 && diffDays <= 7) {
        return 'What will I do next $selectedWeekdayName?';
      } else {
        if (selected.year == today.year + 1) {
          return 'What will I do next year?';
        }
        return 'What will I do that day?';
      }
    }
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format today's date
    final String formattedDate =
        '${_focusedDay.day} ${_getMonthName(_focusedDay.month)} ${_focusedDay.year}';

    // Determine the AppBar title based on the selected/focused day
    String activityTitle;
    final DateTime comparisonDay =
        _selectedDay ??
        _focusedDay; // Prefer selected day, otherwise focused day
    activityTitle = getActivityTitle(comparisonDay);
    return PopScope(
      // Add PopScope to handle back button
      canPop: !_isCalendarVisible, // Allow pop only if calendar is not visible
      onPopInvoked: (didPop) {
        if (didPop) {
          return; // If the system already popped, do nothing
        }
        if (_isCalendarVisible) {
          setState(() {
            _isCalendarVisible = false; // Hide calendar if visible
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 120.0, // Increased height for 3-line layout
          titleSpacing: 8,
          title: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available space dynamically
              final double avatarWidth = 56.0; // radius 28 * 2
              final double actionsWidth = 100.0; // Reduced from 120.0
              final double padding = 8.0; // Reduced from 24.0
              final double availableTextWidth =
                  constraints.maxWidth - avatarWidth - actionsWidth - padding;

              // Dynamic spacing based on available width
              final double spacing = availableTextWidth > 200 ? 12.0 : 8.0;

              // Dynamic font size based on available width
              final double baseFontSize = availableTextWidth > 250
                  ? 18.0
                  : availableTextWidth > 200
                  ? 16.0
                  : 15.0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Emoji Avatar (on left)
                  Consumer<ProfileManager>(
                    builder: (_, profileManager, __) {
                      // Show loading indicator if profiles haven't loaded yet
                      if (!profileManager.isLoaded) {
                        return CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }

                      final emoji =
                          profileManager.currentProfile?.profileImage ?? '🙂';
                      return GestureDetector(
                        onTap: () {
                          _showBottomSheet(
                            context,
                            const ProfileSelectorBottomSheet(),
                          );
                        },
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: spacing),

                  // Text Column with 3 lines - using all remaining space
                  Expanded(
                    child: Consumer<ProfileManager>(
                      builder: (context, profileManager, child) {
                        if (!profileManager.isLoaded) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Loading...',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: baseFontSize,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Please wait...',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: baseFontSize,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withOpacity(0.8),
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Setting up...',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: baseFontSize,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }

                        // Extract greeting and name from animated text
                        final String greeting = _getGreeting();

                        // Parse the animated text to show appropriate parts
                        String greetingText = '';
                        String nameText = '';

                        if (_animatedText.isNotEmpty) {
                          if (_animatedText.length <= greeting.length) {
                            greetingText = _animatedText;
                          } else {
                            greetingText = greeting;
                            final remainingText = _animatedText
                                .substring(greeting.length)
                                .trim();
                            if (remainingText.startsWith('I am ')) {
                              nameText = remainingText;
                            }
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Line 1: Greeting (animated)
                            Text(
                              '$greetingText${_showCursor && _isAnimating && greetingText.length < greeting.length ? "|" : ""}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: baseFontSize,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            // Line 2: "I am [name]" (animated after greeting)
                            Text(
                              '$nameText${_showCursor && _isAnimating && greetingText.length >= greeting.length ? "|" : ""}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: baseFontSize,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            // Line 3: Activity title (static)
                            Text(
                              activityTitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: baseFontSize,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            // Settings Icon Button
            IconButton(
              onPressed: () {
                _showBottomSheet(context, const SettingsBottomSheet());
              },
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // About/More Icon Button
            IconButton(
              onPressed: () {
                _showBottomSheet(context, const AboutBottomSheet());
              },
              icon: const Icon(Icons.info_outline),
              tooltip: 'About',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            // Today's Date Bar (Material 3 Card)
            Padding(
              // Added Padding for overall spacing
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Card(
                elevation: 4, // Increased elevation for a more prominent shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16.0,
                  ), // More rounded corners
                ),
                child: InkWell(
                  // Use InkWell for Material ripple effect on tap
                  onTap: () {
                    setState(() {
                      _isCalendarVisible =
                          !_isCalendarVisible; // Toggle calendar visibility
                    });
                  },
                  borderRadius: BorderRadius.circular(
                    16.0,
                  ), // Match InkWell's ripple to card shape
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, // Increased horizontal padding
                      vertical: 16.0, // Increased vertical padding
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Space out text and icon
                      children: [
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing:
                                      0.5, // Slightly increased letter spacing
                                ),
                          ),
                        ),
                        Icon(
                          _isCalendarVisible
                              ? Icons
                                    .keyboard_arrow_up_rounded // Slightly changed icon for rounded aesthetic
                              : Icons
                                    .keyboard_arrow_down_rounded, // Slightly changed icon
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 28, // Slightly larger icon
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Google Calendar Type View Placeholder
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // "Today" button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                _focusedDay = _focusedDay.subtract(
                                  const Duration(days: 1),
                                );
                                _selectedDay = _focusedDay;
                              });
                            },
                            child: const Text('Previous'),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime.now();
                                _selectedDay = DateTime.now();
                              });
                            },
                            child: const Text('Today'),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                _focusedDay = _focusedDay.add(
                                  const Duration(days: 1),
                                );
                                _selectedDay = _focusedDay;
                              });
                            },
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                    // AnimatedSize to slide the calendar in/out
                    AnimatedSize(
                      duration: const Duration(
                        milliseconds: 300,
                      ), // Animation duration
                      curve: Curves.easeInOut, // Smooth animation curve
                      child: _isCalendarVisible
                          ? Column(
                              children: [
                                TableCalendar(
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2030, 12, 31),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) {
                                    return isSameDay(_selectedDay, day);
                                  },
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay =
                                          focusedDay; // update `_focusedDay` as well
                                    });
                                  },
                                  calendarFormat: CalendarFormat
                                      .month, // Display as a month view
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible:
                                        false, // Hide the format button
                                    titleCentered: true,
                                    leftChevronIcon: Icon(
                                      Icons.chevron_left,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    rightChevronIcon: Icon(
                                      Icons.chevron_right,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    titleTextStyle: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  calendarStyle: CalendarStyle(
                                    todayDecoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    selectedTextStyle: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                    todayTextStyle: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    defaultTextStyle: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    weekendTextStyle: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    outsideTextStyle: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                  onPageChanged: (focusedDay) {
                                    _focusedDay = focusedDay;
                                  },
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'This is a placeholder for your calendar events or daily agenda.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(), // When not visible, shrink to nothing
                    ),
                    const SizedBox(
                      height: 20,
                    ), // Space between calendar and new list

                    const SizedBox(height: 10),
                    // Activities ListView - Display real activities for selected date
                    Consumer<ActivityManager>(
                      builder: (context, activityManager, child) {
                        if (!activityManager.isLoaded) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Get activities for the selected/focused date
                        final selectedDate = _selectedDay ?? _focusedDay;
                        final activities = activityManager.getActivitiesForDate(
                          selectedDate,
                        );

                        if (activities.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 64,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No activities for this day',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to add your first activity!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            final time = TimeOfDay.fromDateTime(
                              activity.activityDatetime,
                            );
                            final timeString = time.format(context);

                            // Determine leading icon based on completion status
                            Icon leadingIcon;
                            if (activity.activityDone) {
                              leadingIcon = Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            } else {
                              leadingIcon = Icon(
                                Icons.radio_button_unchecked,
                                color: Theme.of(context).colorScheme.outline,
                              );
                            }

                            // Build subtitle with location, mood, and tags
                            List<String> subtitleParts = [];
                            subtitleParts.add('$timeString');

                            if (activity.location != null &&
                                activity.location!.isNotEmpty) {
                              subtitleParts.add('📍 ${activity.location!}');
                            }

                            if (activity.activityMood != ActivityMood.happy) {
                              subtitleParts.add(activity.activityMood.emoji);
                            }

                            if (activity.tags.isNotEmpty) {
                              subtitleParts.add(
                                '#${activity.tags.take(2).join(' #')}${activity.tags.length > 2 ? '...' : ''}',
                              );
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 6.0,
                              ),
                              elevation: activity.activityStarred ? 3 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: activity.activityStarred
                                    ? BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.3),
                                      )
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                leading: leadingIcon,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        activity.activityTitle,
                                        style: TextStyle(
                                          decoration: activity.activityDone
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: activity.activityDone
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant
                                              : null,
                                        ),
                                      ),
                                    ),
                                    if (activity.activityStarred)
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    if (activity.checklist.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.checklist,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                    if (activity.activityMedia.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.attachment,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                  subtitleParts.join(' • '),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'toggle_complete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            activity.activityDone
                                                ? Icons.radio_button_unchecked
                                                : Icons.check_circle,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            activity.activityDone
                                                ? 'Mark Incomplete'
                                                : 'Mark Complete',
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'toggle_star',
                                      child: Row(
                                        children: [
                                          Icon(
                                            activity.activityStarred
                                                ? Icons.star_border
                                                : Icons.star,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            activity.activityStarred
                                                ? 'Remove Star'
                                                : 'Add Star',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    switch (value) {
                                      case 'toggle_complete':
                                        await activityManager
                                            .toggleActivityCompletion(
                                              activity.activityId,
                                            );
                                        break;
                                      case 'toggle_star':
                                        await activityManager
                                            .toggleActivityStar(
                                              activity.activityId,
                                            );
                                        break;
                                      case 'delete':
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Delete Activity',
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this activity?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          await activityManager.deleteActivity(
                                            activity.activityId,
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Activity deleted',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        break;
                                    }
                                  },
                                ),
                                onTap: () {
                                  // Show activity details or edit screen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Tapped: ${activity.activityTitle}',
                                      ),
                                      action: SnackBarAction(
                                        label: 'Details',
                                        onPressed: () {
                                          // TODO: Navigate to activity details screen
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Activity Statistics Card
                    Consumer<ActivityManager>(
                      builder: (context, activityManager, child) {
                        if (!activityManager.isLoaded) {
                          return const SizedBox.shrink();
                        }

                        final stats = activityManager.getActivityStats();

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Activity Overview',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem(
                                        context,
                                        icon: Icons.event_note,
                                        label: 'Total',
                                        value: stats['total'].toString(),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      _buildStatItem(
                                        context,
                                        icon: Icons.check_circle,
                                        label: 'Completed',
                                        value: stats['completed'].toString(),
                                        color: Colors.green,
                                      ),
                                      _buildStatItem(
                                        context,
                                        icon: Icons.star,
                                        label: 'Starred',
                                        value: stats['starred'].toString(),
                                        color: Colors.amber,
                                      ),
                                      _buildStatItem(
                                        context,
                                        icon: Icons.today,
                                        label: 'Today',
                                        value: stats['today'].toString(),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showBottomSheet(context, const AddActivityBottomSheet());
          },
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primaryContainer, // Respect theme color
          foregroundColor: Theme.of(
            context,
          ).colorScheme.onPrimaryContainer, // Respect theme color
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
