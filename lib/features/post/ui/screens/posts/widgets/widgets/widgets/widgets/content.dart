part of '../../../../posts_screen.dart';

class _Content extends StatefulWidget {
  final Post post;

  const _Content({required this.post});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(color: colors.surface),
      padding: EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        children: [
          CustomCircleAvatar(url: widget.post.user.avatarUrl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.post.user.name, style: textTheme.labelSmall),
              Text(
                DateFormatter.format(date: widget.post.created),
                style: textTheme.labelSmall?.copyWith(fontSize: 9),
              ),
            ],
          ),
          Spacer(),
          SizedBox(
            width: 24,
            height: 24,
            child: LoadingIconButton(
              padding: EdgeInsets.all(0),
              loading: _deleting,
              alignment: Alignment.center,
              iconSize: 14,
              onPressed: _delete,
              icon: Icon(LucideIcons.trash2, color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _delete() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("حذف مود"),
              content: const Text(
                "مطمئنی میخواد پستت رو پاک کنی؟ آرین بفهمه ناراحت میشه ها 🥲",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("بیخیال"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("حذف"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return false;

    setState(() {
      _deleting = true;
    });

    try {
      await PostRepository().delete(widget.post.id);

      return true;
    } catch (_) {
      if (mounted) {
        AppMessenger.showError(
          context,
          'اینقدر نت خوب بود حذف نشد (اشکال نداره حذفش نکن دیگه)',
        );
      }

      return false;
    } finally {
      setState(() {
        _deleting = false;
      });
    }
  }
}
