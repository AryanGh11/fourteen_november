import 'package:flutter/material.dart';
import 'package:fourteen_november/theme/app_theme.dart';
import 'package:fourteen_november/core/router/app_router.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.initialize();

  await PocketBaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '14 November',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
