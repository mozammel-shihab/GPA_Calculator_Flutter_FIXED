import 'dart:ui';

import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/onboarding.dart';
import 'screens/splash.dart';
import 'screens/shell.dart';
import 'services/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'GPA Calculator Pro',
        context: ErrorDescription('during app startup or runtime flow'),
      ),
    );
    return true;
  };

  final store = await AppStore.create();
  runApp(GpaApp(store: store));
}

class GpaApp extends StatefulWidget {
  const GpaApp({super.key, required this.store});

  final AppStore store;

  @override
  State<GpaApp> createState() => _GpaAppState();
}

class _GpaAppState extends State<GpaApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final seed = const Color(0xFF6750A4);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GPA Calculator Pro',
          themeMode: widget.store.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seed,
            brightness: Brightness.light,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
            cardTheme: const CardThemeData(margin: EdgeInsets.zero),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seed,
            brightness: Brightness.dark,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
            cardTheme: const CardThemeData(margin: EdgeInsets.zero),
          ),
          home: AppEntry(store: widget.store),
        );
      },
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key, required this.store});

  final AppStore store;

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SplashScreen();
    if (!widget.store.onboardingComplete) {
      return OnboardingScreen(store: widget.store);
    }
    return widget.store.loggedIn
        ? Shell(store: widget.store)
        : LoginScreen(store: widget.store);
  }
}
