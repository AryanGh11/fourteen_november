part of '../../weather_screen.dart';

class _WidgetSkeleton extends StatelessWidget {
  const _WidgetSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            ShimmerPlaceholder(width: 32, height: 32, borderRadius: 9999),
            ShimmerPlaceholder(width: 50, height: 20),
          ],
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          padding: EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
              spacing: 10,
                children: [
                  ShimmerPlaceholder(width: 100, height: 20),
                  ShimmerPlaceholder(width: 60, height: 65),
                  ShimmerPlaceholder(width: 60, height: 20),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                child: ShimmerPlaceholder(width: 50, height: 50),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
