part of '../home_screen.dart';

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final name = UserProviderService().current?.name;
    final currentUser = UserProviderService().current;
    final moods =
        MoodRepository()
            .getAll()
            .where((mood) => mood.userId == currentUser?.id)
            .toList()
          ..sort((a, b) => b.created.compareTo(a.created));
    final posts = PostRepository().getAll()
      ..sort((a, b) => b.created.compareTo(a.created));

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 10),
        Text(
          DateFormat('EEEE · MMMM d').format(DateTime.now()),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${DateTime.now().hour < 12
              ? 'Good morning'
              : DateTime.now().hour < 18
              ? 'Good afternoon'
              : 'Good evening'}${name == null || name.isEmpty ? '' : ', $name'}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          'A little place for everything that’s us.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 18),
        _StoryCard(onTap: () => context.push(RouteProvider.stats)),
        _SectionTitle(
          title: 'How are you feeling?',
          action: 'See moods',
          onTap: () => context.push(RouteProvider.moods),
        ),
        _MoodCard(
          mood: moods.isEmpty ? null : moods.first,
          onTap: () => context.push(RouteProvider.moods),
        ),
        _SectionTitle(
          title: 'Little moments',
          action: 'All memories',
          onTap: () => context.push(RouteProvider.posts),
        ),
        _MemoryCard(
          post: posts.isEmpty ? null : posts.first,
          onTap: () => context.push(RouteProvider.posts),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          childAspectRatio: .92,
          children: [
            _QuickLink(
              title: 'Gym',
              icon: LucideIcons.dumbbell,
              onTap: () => context.push(RouteProvider.gym),
            ),
            _QuickLink(
              title: 'Period',
              icon: LucideIcons.calendarHeart,
              onTap: () => context.push(RouteProvider.periods),
            ),
            _QuickLink(
              title: 'Weather',
              icon: LucideIcons.cloudSun,
              onTap: () => context.push(RouteProvider.weather),
            ),
            _QuickLink(
              title: 'Our stats',
              icon: LucideIcons.chartNoAxesColumn,
              onTap: () => context.push(RouteProvider.stats),
            ),
            _QuickLink(
              title: 'Backgrounds',
              icon: LucideIcons.images,
              onTap: () => context.push(RouteProvider.backgrounds),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
