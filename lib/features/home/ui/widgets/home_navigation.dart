part of '../home_screen.dart';

class _HomeNavigation extends StatelessWidget {
  const _HomeNavigation();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: colors.onSurface.withValues(alpha: .08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: LucideIcons.house,
                label: 'Home',
                selected: true,
                onTap: () {},
              ),
              _NavItem(
                icon: LucideIcons.smile,
                label: 'Moods',
                onTap: () => context.push(RouteProvider.moods),
              ),
              Material(
                color: colors.primary,
                borderRadius: BorderRadius.circular(17),
                child: InkWell(
                  borderRadius: BorderRadius.circular(17),
                  onTap: () => context.push(RouteProvider.newPost),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(LucideIcons.plus, color: colors.onPrimary),
                  ),
                ),
              ),
              _NavItem(
                icon: LucideIcons.heart,
                label: 'Memories',
                onTap: () => context.push(RouteProvider.posts),
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: 'Profile',
                onTap: () => context.push(RouteProvider.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 57,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
