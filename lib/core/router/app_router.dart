import 'package:go_router/go_router.dart';
import 'package:fourteen_november/features/gift/gift.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/stats/stats.dart';
import 'package:fourteen_november/features/period/period.dart';
import 'package:fourteen_november/features/profile/profile.dart';
import 'package:fourteen_november/features/weather/weather.dart';
import 'package:fourteen_november/core/router/route_provider.dart';
import 'package:fourteen_november/features/gym/ui/gym_screen.dart';
import 'package:fourteen_november/features/home/ui/home_screen.dart';
import 'package:fourteen_november/features/mood/ui/mood_screen.dart';
import 'package:fourteen_november/features/background/background.dart';

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
      path: RouteProvider.gym,
      builder: (context, state) => const GymScreen(),
    ),

    GoRoute(
      path: RouteProvider.periods,
      builder: (context, state) {
        return PeriodScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.posts,
      builder: (context, state) {
        return PostsScreen();
      },
    ),
    GoRoute(
      path: RouteProvider.newPost,
      builder: (context, state) {
        return NewPostScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.weather,
      builder: (context, state) {
        return WeatherScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.stats,
      builder: (context, state) {
        return StatsScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.backgrounds,
      builder: (context, state) {
        return BackgroundsScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.profile,
      builder: (context, state) {
        return ProfileScreen();
      },
    ),

    GoRoute(
      path: RouteProvider.giftPattern,
      builder: (context, state) {
        return GiftScreen(giftId: state.pathParameters['id']!);
      },
    ),
  ],
);
