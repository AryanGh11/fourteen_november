part of '../home_screen.dart';

class _MoodCard extends StatelessWidget {
  final Mood? mood;
  final VoidCallback onTap;
  const _MoodCard({required this.mood, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final labels = ['Rough', 'Low', 'Okay', 'Good', 'Amazing'];
    final value = mood?.value ?? 0;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    mood == null
                        ? LucideIcons.smilePlus
                        : Mood.getIconForValue(value),
                    color: mood == null
                        ? Theme.of(context).colorScheme.primary
                        : Mood.getColorForValue(value),
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mood == null
                              ? 'Check in with yourself'
                              : 'Your latest check-in: ${labels[value.clamp(1, 5) - 1]}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          mood == null
                              ? 'A small moment just for you'
                              : DateFormat(
                                  'MMM d · h:mm a',
                                ).format(mood!.created),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.plus,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (i) => Icon(
                    Mood.getIconForValue(i + 1),
                    size: 22,
                    color: mood?.value == i + 1
                        ? Mood.getColorForValue(i + 1)
                        : Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
