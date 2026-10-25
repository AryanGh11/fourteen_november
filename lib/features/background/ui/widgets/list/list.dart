part of '../../backgrounds_screen.dart';

/// Horizontal pager, one full screen background per page.
class _List extends StatelessWidget {
  final List<Background> backgrounds;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTap;

  const _List({
    required this.backgrounds,
    required this.controller,
    required this.onPageChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: backgrounds.length,
      onPageChanged: (index) {
        onPageChanged(index);
        _precacheNeighbours(context, index);
      },
      itemBuilder: (context, index) {
        // The first page never fires onPageChanged, so its neighbour is
        // warmed from here instead.
        if (index == 0) _precacheNeighbours(context, 0);

        return GestureDetector(
          onTap: onTap,
          child: _Tile(background: backgrounds[index]),
        );
      },
    );
  }

  /// Starts loading the pages either side of [index] before they are swiped
  /// to, so on a slow connection the next image is usually already there
  /// instead of loading in from blank. Already cached images cost nothing.
  void _precacheNeighbours(BuildContext context, int index) {
    for (final i in [index - 1, index + 1]) {
      if (i < 0 || i >= backgrounds.length) continue;

      precacheImage(
        CachedNetworkImageProvider(backgrounds[i].imageUrl),
        context,
        // A failed warm-up is not worth reporting; the page itself will
        // retry and show its own error state if it still cannot load.
        onError: (_, __) {},
      );
    }
  }
}
