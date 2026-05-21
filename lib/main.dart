import 'package:flutter/material.dart';
import 'package:fourteen_november/theme/app_theme.dart';
import 'package:fourteen_november/features/splash/splash.dart';
import 'package:fourteen_november/core/router/app_router.dart';
import 'package:fourteen_november/core/bootstrap/app_initializer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: '14 November',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }

  Future<void> _initialize() async {
    while (true) {
      try {
        await AppInitializer.init();

        if (!mounted) return;

        setState(() {
          _initialized = true;
        });

        return;
      } catch (e) {
        debugPrint(e.toString());

        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }
}
