import 'package:flutter/material.dart';
import 'package:hello_world/screen/home_screen.dart';
import 'package:hello_world/service/theme_manager.dart';
import 'package:hello_world/service/profile_manager.dart';
import 'package:provider/provider.dart';

import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
// import 'package:provider/provider.dart'; // For PlatformException

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => ProfileManager()),
      ],
      child: const MyApp(),
    ),
  );
}

// Function to handle local authentication
// This function can be called on app start and when app resumes
Future<bool> _authenticateUser() async {
  final LocalAuthentication auth = LocalAuthentication();
  bool canCheckBiometrics = false;
  bool isDeviceSupported = false;
  bool didAuthenticate = false;

  try {
    // Check if the device has biometric hardware
    canCheckBiometrics = await auth.canCheckBiometrics;
    // Check if the device supports any form of local authentication (biometrics or device credentials)
    isDeviceSupported = await auth.isDeviceSupported();
  } on PlatformException catch (e) {
    print("Error checking biometrics/device support: $e");
    // If there's an error checking, assume no authentication is possible or allowed
    return false;
  }

  // Proceed with authentication only if the device has some form of local authentication capability
  if (canCheckBiometrics || isDeviceSupported) {
    try {
      didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth:
              true, // Keep the authentication dialog visible if the app goes to the background
          useErrorDialogs:
              true, // Show system-provided error dialogs for issues
          biometricOnly: false, // Allow fallback to device PIN/Pattern/Passcode
        ),
      );
    } on PlatformException catch (e) {
      print("Authentication error: $e");
      // Handle specific authentication errors
      if (e.code == 'notAvailable' || e.code == 'notEnrolled') {
        // Device has no biometrics set up, or no passcode.
        // You might decide to allow access or prompt the user to set up.
        // For this example, we'll treat it as a failed authentication for strictness.
        print("Local authentication not available or not enrolled.");
      } else if (e.code == 'lockedOut' || e.code == 'permanentlyLockedOut') {
        // User has tried too many times and is locked out
        print("User is locked out of authentication.");
      } else if (e.code == 'auth_error') {
        // Generic authentication error
        print("Generic authentication error occurred.");
      }
      return false; // Authentication failed due to an exception
    }
  } else {
    // If no local authentication is available (e.g., very old device, or no lock screen setup)
    print("No local authentication hardware or setup found on this device.");
    // Decide your policy here:
    // return true; // Allow access if no lock screen is configured
    // return false; // Force a lock screen setup or exit
    return true; // For now, allow access if no lock screen is configured
  }

  return didAuthenticate;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Track if the app is currently authenticated to display content
  bool _isAuthenticated = false;
  // Flag to ensure initial authentication attempt runs only once
  bool _initialAuthAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Perform initial authentication when the app starts
    _performAuthentication();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle app lifecycle changes for re-authentication
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App is coming to the foreground, re-authenticate if not already authenticated
      if (!_isAuthenticated) {
        _performAuthentication();
      }
    } else if (state == AppLifecycleState.paused) {
      // App is going to the background, reset authentication status
      _isAuthenticated = false;
    }
  }

  // Centralized function to perform authentication
  Future<void> _performAuthentication() async {
    if (_initialAuthAttempted && _isAuthenticated) {
      // If already authenticated and initial attempt done, no need to re-authenticate
      return;
    }

    setState(() {
      _initialAuthAttempted = true; // Mark initial attempt
    });

    // Check if lock is enabled in settings
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    if (!themeManager.isLockEnabled) {
      // Lock is disabled, allow access without authentication
      setState(() {
        _isAuthenticated = true;
      });
      return;
    }

    bool authenticated = await _authenticateUser();

    if (mounted) {
      setState(() {
        _isAuthenticated = authenticated;
      });

      // If authentication failed, you might want to exit the app or keep showing a locked screen
      if (!authenticated) {
        // Option 1: Exit the app (more secure but abrupt UX)
        // SystemNavigator.pop();

        // Option 2: Keep showing the locked screen and allow retries
        // The UI will already be showing the LockedScreen if _isAuthenticated is false
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    // If not authenticated, show a locked screen
    if (!_isAuthenticated) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeManager.currentTheme(null), // Apply theme to lock screen
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 20),
                Text(
                  'App Locked',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please authenticate to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _performAuthentication, // Retry authentication
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Authenticate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If authenticated, show the main app content
    return MaterialApp(
      title: 'Material 3 App',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: themeManager.seedColor),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeManager.seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      themeMode: themeManager.themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
