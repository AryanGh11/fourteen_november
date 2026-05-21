part of '../../home_screen.dart';

class _Tiles extends StatelessWidget {
  const _Tiles();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _Tile(
          title: "Moods",
          icon: LucideIcons.smilePlus,
          onTap: () => _navigateTo(context, RouteProvider.moods),
        ),
        _Tile(
          title: "Future",
          icon: LucideIcons.star,
          onTap: () => _navigateTo(context, RouteProvider.home),
          disabled: true,
        ),
        _Tile(
          title: "Notes",
          icon: LucideIcons.bookOpen,
          onTap: () => _navigateTo(context, RouteProvider.home),
          disabled: true,
        ),
        _Tile(
          title: "Stats",
          icon: LucideIcons.barChart2,
          onTap: () => _navigateTo(context, RouteProvider.home),
          disabled: true,
        ),
        _Tile(
          title: "Weather",
          icon: LucideIcons.cloudSun,
          onTap: () => _navigateTo(context, RouteProvider.home),
          disabled: true,
        ),
        _Tile(
          title: "Our Memories",
          icon: LucideIcons.heartPulse,
          onTap: () => _navigateTo(context, RouteProvider.posts),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, String path) {
    context.push(path);
  }
}
