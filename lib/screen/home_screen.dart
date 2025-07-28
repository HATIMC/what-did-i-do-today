import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hello_world/features/settings_bottom_sheet.dart'; // Updated import path
import 'package:hello_world/features/about_bottom_sheet.dart'; // Updated import path
import 'package:hello_world/features/add_activity_bottom_sheet.dart'; // New import for add activity bottom sheet
import 'package:hello_world/service/profile_manager.dart';
import 'package:hello_world/service/theme_manager.dart'; // Import theme manager
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

      // Check if both theme and profile are ready
      if (themeManager.preferencesLoaded &&
          profileManager.currentProfile != null &&
          !_hasInitialGreetingAnimated) {
        _startGreetingAnimation();
        _hasInitialGreetingAnimated = true;
      } else if (!themeManager.preferencesLoaded ||
          profileManager.currentProfile == null) {
        // Listen to both managers for changes
        themeManager.addListener(_startInitialGreetingOnPreferencesLoad);
        profileManager.addListener(_startInitialGreetingOnPreferencesLoad);
      }
    });
  }

  void _startInitialGreetingOnPreferencesLoad() {
    if (!mounted) return;

    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final profileManager = Provider.of<ProfileManager>(context, listen: false);

    if (themeManager.preferencesLoaded &&
        profileManager.currentProfile != null &&
        !_hasInitialGreetingAnimated) {
      _startGreetingAnimation();
      _hasInitialGreetingAnimated = true;
      // Remove both listeners
      themeManager.removeListener(_startInitialGreetingOnPreferencesLoad);
      profileManager.removeListener(_startInitialGreetingOnPreferencesLoad);
    }
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    // Remove listeners from both managers
    if (mounted) {
      Provider.of<ThemeManager>(
        context,
        listen: false,
      ).removeListener(_startInitialGreetingOnPreferencesLoad);
      Provider.of<ProfileManager>(
        context,
        listen: false,
      ).removeListener(_startInitialGreetingOnPreferencesLoad);
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

    final int todayWeekday = today.weekday; // 1 (Mon) to 7 (Sun)
    final int selectedWeekday = selected.weekday;

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
          toolbarHeight: 80.0,
          titleSpacing: 16,
          title: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Emoji Avatar (on left)
                  Consumer<ProfileManager>(
                    builder: (_, profileManager, __) {
                      final emoji =
                          profileManager.currentProfile?.profileImage ?? '🙂';
                      return CircleAvatar(
                        radius: 26,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Text Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // First text (greeting) - smaller
                        SizedBox(
                          width: maxWidth * 0.7,
                          child: Text(
                            '$_animatedText${_showCursor && _isAnimating ? "|" : ""}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      MediaQuery.of(context).size.width *
                                      0.035, // Dynamic font size
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Second text (activity title) - larger
                        SizedBox(
                          width: maxWidth * 0.7,
                          child: Text(
                            activityTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width *
                                      0.045, // Dynamic font size, larger than first
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'settings') {
                  _showBottomSheet(context, const SettingsBottomSheet());
                } else if (result == 'about') {
                  _showBottomSheet(context, const AboutBottomSheet());
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('Settings'),
                ),
                const PopupMenuItem<String>(
                  value: 'about',
                  child: Text('About'),
                ),
              ],
            ),
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
                    ListView.builder(
                      shrinkWrap: true, // Important for nested scrollables
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                      itemCount: 5, // Number of dummy items
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              'Activity ${index + 1}: Completed task X',
                            ),
                            subtitle: Text(
                              'Time: ${9 + index}:00 AM - Details about task ${index + 1}.',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              // Handle tap on activity item
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tapped on Activity ${index + 1}',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                    const Text('End of daily activities.'),
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
