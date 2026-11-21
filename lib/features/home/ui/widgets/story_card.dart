part of '../home_screen.dart';

class _StoryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _StoryCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 174,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.surfaceContainerHigh,
                AppColors.primary.withValues(alpha: .32),
                AppColors.accent.withValues(alpha: .30),
              ],
            ),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 8,
                top: 2,
                child: Icon(
                  LucideIcons.heart,
                  size: 76,
                  color: AppColors.accent.withValues(alpha: .32),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALWAYS FINDING OUR WAY BACK',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.15,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Closer than\nthe miles between.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Our story  ↗',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
