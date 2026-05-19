import 'package:go_router/go_router.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/core/router/route_provider.dart';
import 'package:fourteen_november/features/mood/ui/mood_screen.dart';
import 'package:fourteen_november/features/home/ui/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteProvider.home,
  routes: [
    GoRoute(
      path: RouteProvider.home,
      builder: (context, state) {
        return HomeScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.moods,
      builder: (context, state) {
        return MoodScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.memories,
      builder: (context, state) {
        return MemoriesScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.newMemory,
      builder: (context, state) {
        return NewMemoryScreen();
      },
    ),
  ],
);
