part of '../weather_screen.dart';

class _View extends StatelessWidget {
  final List<Weather>? cities;
  final Future<void> Function() onRefresh;

  const _View({required this.cities, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await onRefresh(),
      child: cities == null
          ? ListView.separated(
              itemBuilder: (_, __) {
                return _WidgetSkeleton();
              },
              separatorBuilder: (_, __) => SizedBox(height: 40),
              itemCount: 2,
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                final item = cities![index];
                return _Widget(weather: item);
              },
              separatorBuilder: (_, __) => SizedBox(height: 40),
              itemCount: cities!.length,
            ),
    );
  }
}
