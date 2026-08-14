import 'package:flutter/material.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fourteen_november/features/weather/weather.dart';
import 'package:fourteen_november/shared/shimmer_placeholder.dart';
import 'package:fourteen_november/shared/custom_circle_avatar.dart';
import 'package:fourteen_november/core/utils/date_formatter/date_formatter.dart';

part 'widgets/view.dart';
part 'widgets/widgets/widget.dart';
part 'widgets/widgets/widget_skeleton.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _weatherRepository = WeatherRepository();

  List<Weather>? _cities;

  @override
  void initState() {
    super.initState();

    // Update user's location
    UserProviderService().updateLocation();

    _initCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text("Weather")),
      body: AppWrapper(
        child: Center(
          child: _View(cities: _cities, onRefresh: _refresh),
        ),
      ),
    );
  }

  Future<void> _initCities() async {
    final allUsers = UserRepository().getAll();

    final List<Weather> cities = [];

    // One card per person rather than per place: each card is tied to a user's
    // avatar, so two people in the same city should still both appear.
    for (final user in allUsers) {
      final res = await _weatherRepository.getCurrentFor(user: user);

      cities.add(res);
    }

    setState(() {
      _cities = cities;
    });
  }

  Future<void> _refresh() async {
    try {
      await _initCities();
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(context, 'نت عالیه! یبار دیگه بزن نفس');
    }
  }
}
