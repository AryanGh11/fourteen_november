part of '../home_screen.dart';

class _MemoryCard extends StatelessWidget {
  final Post? post;
  final VoidCallback onTap;
  const _MemoryCard({required this.post, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: SizedBox(
        height: 104,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (post != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 82,
                    height: 82,
                    child: CustomCachedNetworkImage(
                      imageUrl: post!.attachmentUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.heart, color: AppColors.accent),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post == null
                          ? 'Make a little memory'
                          : 'A moment to keep',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post == null || post!.description.isEmpty
                          ? 'Your favorite kind of day'
                          : post!.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      post == null
                          ? 'Share something together'
                          : DateFormat('MMM d').format(post!.created),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.heart, color: AppColors.accent),
            ],
          ),
        ),
      ),
    ),
  );
}
