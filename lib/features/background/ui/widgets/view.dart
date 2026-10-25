part of '../backgrounds_screen.dart';

/// The swiper, with a page counter over the bottom and pull to refresh.
class _View extends StatelessWidget {
  final List<Background> backgrounds;
  final int index;
  final PageController controller;
  final bool chromeVisible;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onToggleChrome;

  const _View({
    required this.backgrounds,
    required this.index,
    required this.controller,
    required this.chromeVisible,
    required this.onRefresh,
    required this.onPageChanged,
    required this.onToggleChrome,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await onRefresh(),
      // Body runs behind the app bar, so the indicator is pushed down below it
      // rather than appearing underneath.
      edgeOffset: MediaQuery.paddingOf(context).top,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // A horizontal pager produces no vertical overscroll for the
          // indicator to react to. Wrapping it in an always-scrollable
          // vertical view, exactly one screen tall, supplies that while
          // leaving horizontal swipes to the pager. It also keeps refresh
          // reachable when the list is empty.
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: backgrounds.isEmpty
                  ? const _Empty()
                  : _buildPager(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPager(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _List(
          backgrounds: backgrounds,
          controller: controller,
          onPageChanged: onPageChanged,
          onTap: onToggleChrome,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: chromeVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: _Counter(
                      current: index + 1,
                      total: backgrounds.length,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(
            LucideIcons.imagePlus,
            size: 40,
            color: colors.onSurface.withValues(alpha: 0.4),
          ),
          Text(
            "No backgrounds yet",
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// "3 / 11" in a small translucent pill, readable over any photo.
class _Counter extends StatelessWidget {
  final int current;
  final int total;

  const _Counter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$current / $total",
        style: textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
